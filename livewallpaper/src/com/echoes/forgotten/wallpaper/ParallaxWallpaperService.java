package com.echoes.forgotten.wallpaper;

import android.content.Context;
import android.content.SharedPreferences;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Paint;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.RadialGradient;
import android.graphics.Shader;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.os.SystemClock;
import android.service.wallpaper.WallpaperService;
import android.util.Log;
import android.view.SurfaceHolder;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.Random;

/**
 * Live wallpaper: the watching flower, with layered tilt parallax.
 * Layers, back to front: background plate, two mist layers, flower cutout (with a living eye),
 * eye glow, spores, vignette. All layer art is authored on a 1080x2340 reference canvas and
 * scaled to cover the screen.
 */
public class ParallaxWallpaperService extends WallpaperService {
    private static final String TAG = "EchoesWallpaper";

    @Override
    public Engine onCreateEngine() {
        return new ParallaxEngine();
    }

    private class ParallaxEngine extends Engine implements SensorEventListener {
        private static final float REF_W = 1080f;
        private static final float REF_H = 2340f;
        private static final long FRAME_MS = 33;

        // How far each layer slides (reference px) at full tilt. Larger = nearer to the viewer.
        private static final float DEPTH_BG = 14f;
        private static final float DEPTH_FOG = 24f;
        private static final float DEPTH_FLOWER = 40f;
        private static final float DEPTH_SPORES = 52f;
        // Edge margin for the layers that fill the screen, so a shift never reveals their border.
        private static final float OVERSCAN = 1.06f;

        // Tilt response: roll/pitch (as a fraction of gravity) that counts as "full tilt".
        private static final float TILT_RANGE = 0.30f;
        private static final float RECENTER_SECONDS = 5f;

        private static final float MIST_SPEED = 40f; // reference px per second
        private static final float MIST_PERIOD = 360f;

        private static final int SPORE_COUNT = 28;
        private static final float SPORE_LIFE = 18f;

        // The flower cutout sits at this y on the reference canvas.
        private static final float FLOWER_Y = 640f;

        // Eye region inside the flower bitmap, and the geometry of the eye in that bitmap.
        private static final int EYE_X = 457, EYE_Y = 300, EYE_W = 200, EYE_H = 150;
        private static final int MESH_W = 80, MESH_H = 60;
        private static final float PUPIL_X = 557.5f, PUPIL_Y = 374f;   // pupil centre
        private static final float IRIS_X = 557.5f, IRIS_Y = 382f;     // centre the look-around moves
        private static final float PUPIL_BASE = 15.5f;                 // pupil radius in the art
        private static final float WARP_RADIUS = 40f;

        // Drawing-backend safety net: 0 untried, 1 hardware attempt in flight, 2 hardware proven, 3 use software.
        private static final String PREFS = "echoes_wallpaper";
        private static final String KEY_HW = "hw_state";
        private static final int HW_PROVEN_AFTER_FRAMES = 90;

        private final Handler handler = new Handler(Looper.getMainLooper());
        private final Runnable ticker = new Runnable() {
            @Override
            public void run() {
                drawFrame();
                if (visible) {
                    handler.postDelayed(this, FRAME_MS);
                }
            }
        };

        private Bitmap bg, flower, eye, fog1, fog2, vignette, sprite;
        private final Paint plain = new Paint(Paint.FILTER_BITMAP_FLAG | Paint.ANTI_ALIAS_FLAG);
        private final Paint screen = new Paint(Paint.FILTER_BITMAP_FLAG | Paint.ANTI_ALIAS_FLAG);
        private final Paint glow = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final Paint errorPaint = new Paint(Paint.ANTI_ALIAS_FLAG);
        private final float[] eyeMesh = new float[(MESH_W + 1) * (MESH_H + 1) * 2];

        private float viewW, viewH, scale, offX, offY;
        private boolean visible;
        private long startMs;
        private long lastMs;

        private SharedPreferences prefs;
        private boolean useHardware;
        private int hwFrames;
        private String errorText;

        private SensorManager sensorManager;
        private Sensor accel;
        private float rawRoll, rawPitch;       // low-passed accelerometer readout
        private float baseRoll, basePitch;     // slowly follows the readout so the wallpaper recenters
        private boolean haveSample;
        private float tiltX, tiltY;            // smoothed, -1..1

        private final float[] sx = new float[SPORE_COUNT];
        private final float[] sy = new float[SPORE_COUNT];
        private final float[] sdx = new float[SPORE_COUNT];
        private final float[] sdy = new float[SPORE_COUNT];
        private final float[] samp = new float[SPORE_COUNT];
        private final float[] sk = new float[SPORE_COUNT];
        private final float[] sph = new float[SPORE_COUNT];
        private final float[] ssw = new float[SPORE_COUNT];
        private final float[] srad = new float[SPORE_COUNT];
        private final float[] sbri = new float[SPORE_COUNT];

        @Override
        public void onCreate(SurfaceHolder holder) {
            super.onCreate(holder);
            Context ctx = ParallaxWallpaperService.this;
            startMs = SystemClock.uptimeMillis();
            lastMs = startMs;

            // If the previous run died while still on the hardware canvas, stay on software for good.
            prefs = ctx.getSharedPreferences(PREFS, Context.MODE_PRIVATE);
            int state = prefs.getInt(KEY_HW, 0);
            if (state == 1) {
                state = 3;
                prefs.edit().putInt(KEY_HW, 3).commit();
            }
            useHardware = Build.VERSION.SDK_INT >= 26 && state != 3;

            try {
                bg = load("bg.jpg");
                flower = load("flower.png");
                fog1 = load("fog1.png");
                fog2 = load("fog2.png");
                vignette = load("vignette.png");
                sprite = makeSprite();
                if (flower != null) {
                    eye = Bitmap.createBitmap(flower, EYE_X, EYE_Y, EYE_W, EYE_H);
                }
                if (bg == null || flower == null || fog1 == null || fog2 == null || vignette == null) {
                    throw new IOException("a wallpaper image failed to load");
                }

                screen.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SCREEN));
                glow.setXfermode(new PorterDuffXfermode(PorterDuff.Mode.SCREEN));
                glow.setShader(new RadialGradient(0f, 0f, 150f,
                        new int[] {0xFFBFE699, 0x80BFE699, 0x00BFE699},
                        new float[] {0f, 0.45f, 1f}, Shader.TileMode.CLAMP));
                initSpores();
            } catch (Throwable t) {
                fail(t);
            }

            errorPaint.setColor(Color.WHITE);
            errorPaint.setTextSize(30f);

            sensorManager = (SensorManager) ctx.getSystemService(Context.SENSOR_SERVICE);
            if (sensorManager != null) {
                accel = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            }
        }

        private Bitmap load(String name) throws IOException {
            InputStream in = getAssets().open(name);
            try {
                BitmapFactory.Options o = new BitmapFactory.Options();
                o.inScaled = false;
                o.inPreferredConfig = Bitmap.Config.ARGB_8888;
                return BitmapFactory.decodeStream(in, null, o);
            } finally {
                in.close();
            }
        }

        private Bitmap makeSprite() {
            int size = 64;
            Bitmap b = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
            Canvas c = new Canvas(b);
            Paint p = new Paint(Paint.ANTI_ALIAS_FLAG);
            p.setShader(new RadialGradient(size / 2f, size / 2f, size / 2f,
                    new int[] {0xFFFFEBA8, 0x99FFD070, 0x00FFC060},
                    new float[] {0f, 0.35f, 1f}, Shader.TileMode.CLAMP));
            c.drawCircle(size / 2f, size / 2f, size / 2f, p);
            return b;
        }

        // Spores are born inside the flower body and drift up and away over SPORE_LIFE seconds.
        private void initSpores() {
            Random r = new Random(11);
            for (int i = 0; i < SPORE_COUNT; i++) {
                double a = r.nextDouble() * Math.PI * 2;
                double d = Math.sqrt(r.nextDouble());
                sx[i] = (float) (540 + d * Math.cos(a) * 312);
                sy[i] = (float) (1000 + d * Math.sin(a) * 264);
                sph[i] = (float) ((i + r.nextDouble() * 0.6) / SPORE_COUNT);
                sdy[i] = 280f + r.nextFloat() * 360f;
                sdx[i] = (r.nextFloat() * 2f - 1f) * 112f;
                samp[i] = 8f + r.nextFloat() * 12f;
                sk[i] = 1 + r.nextInt(2);
                ssw[i] = r.nextFloat();
                srad[i] = 10f + r.nextFloat() * 12f;
                sbri[i] = 0.55f + r.nextFloat() * 0.45f;
            }
        }

        /** Remember the failure, log it, and keep a copy where it can be found; the wallpaper then shows it. */
        private void fail(Throwable t) {
            Log.e(TAG, "wallpaper error", t);
            StringWriter sw = new StringWriter();
            t.printStackTrace(new PrintWriter(sw));
            errorText = sw.toString();
            try {
                FileOutputStream out = openFileOutput("last_error.txt", Context.MODE_PRIVATE);
                out.write(errorText.getBytes("UTF-8"));
                out.close();
            } catch (Throwable ignored) {
            }
        }

        @Override
        public void onSurfaceChanged(SurfaceHolder holder, int format, int width, int height) {
            super.onSurfaceChanged(holder, format, width, height);
            viewW = width;
            viewH = height;
            scale = Math.max(viewW / REF_W, viewH / REF_H);
            offX = (viewW - REF_W * scale) / 2f;
            offY = (viewH - REF_H * scale) / 2f;
            drawFrame();
        }

        @Override
        public void onVisibilityChanged(boolean isVisible) {
            visible = isVisible;
            handler.removeCallbacks(ticker);
            if (isVisible) {
                if (sensorManager != null && accel != null) {
                    sensorManager.registerListener(this, accel, SensorManager.SENSOR_DELAY_GAME);
                }
                lastMs = SystemClock.uptimeMillis();
                handler.post(ticker);
            } else if (sensorManager != null) {
                sensorManager.unregisterListener(this);
                haveSample = false;
            }
        }

        @Override
        public void onSurfaceDestroyed(SurfaceHolder holder) {
            super.onSurfaceDestroyed(holder);
            visible = false;
            handler.removeCallbacks(ticker);
            if (sensorManager != null) {
                sensorManager.unregisterListener(this);
            }
        }

        @Override
        public void onDestroy() {
            super.onDestroy();
            visible = false;
            handler.removeCallbacks(ticker);
            if (sensorManager != null) {
                sensorManager.unregisterListener(this);
            }
            // Bitmaps are left for the GC: the render thread may still hold them for a frame.
        }

        @Override
        public void onSensorChanged(SensorEvent e) {
            float x = e.values[0];
            float y = e.values[1];
            float z = e.values[2];
            float n = (float) Math.sqrt(x * x + y * y + z * z);
            if (n < 1f) {
                return;
            }
            float roll = x / n;   // left/right tilt
            float pitch = z / n;  // top toward/away from the viewer
            if (!haveSample) {
                rawRoll = baseRoll = roll;
                rawPitch = basePitch = pitch;
                haveSample = true;
            }
            rawRoll += 0.2f * (roll - rawRoll);
            rawPitch += 0.2f * (pitch - rawPitch);
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
        }

        private void updateTilt(float dt) {
            float k = Math.min(1f, dt / RECENTER_SECONDS);
            baseRoll += k * (rawRoll - baseRoll);
            basePitch += k * (rawPitch - basePitch);
            float targetX = clamp((rawRoll - baseRoll) / TILT_RANGE);
            float targetY = clamp((rawPitch - basePitch) / TILT_RANGE);
            float ease = Math.min(1f, dt * 4f);
            tiltX += ease * (targetX - tiltX);
            tiltY += ease * (targetY - tiltY);
        }

        private float clamp(float v) {
            return Math.max(-1f, Math.min(1f, v));
        }

        private void drawFrame() {
            if (viewW <= 0) {
                return;
            }
            long now = SystemClock.uptimeMillis();
            float dt = Math.min(0.1f, (now - lastMs) / 1000f);
            lastMs = now;
            float t = (now - startMs) / 1000f;
            if (errorText == null) {
                updateTilt(dt);
            }

            SurfaceHolder holder = getSurfaceHolder();
            Canvas c = null;
            boolean hardware = useHardware && errorText == null;
            try {
                if (hardware && hwFrames == 0) {
                    // Mark the attempt before touching the GPU path; cleared once it has run long enough.
                    prefs.edit().putInt(KEY_HW, 1).commit();
                }
                c = hardware ? holder.getSurface().lockHardwareCanvas() : holder.lockCanvas();
                if (c != null) {
                    if (errorText != null) {
                        renderError(c);
                    } else {
                        render(c, t);
                    }
                }
            } catch (Throwable th) {
                if (hardware) {
                    // Fall back to the software canvas and keep going.
                    Log.w(TAG, "hardware canvas failed, switching to software", th);
                    useHardware = false;
                    prefs.edit().putInt(KEY_HW, 3).commit();
                } else {
                    fail(th);
                }
            } finally {
                if (c != null) {
                    try {
                        holder.unlockCanvasAndPost(c);
                    } catch (Throwable ignored) {
                    }
                }
            }

            if (hardware && useHardware && errorText == null && ++hwFrames == HW_PROVEN_AFTER_FRAMES) {
                prefs.edit().putInt(KEY_HW, 2).commit();
            }
        }

        private void renderError(Canvas c) {
            c.drawColor(0xFF200000);
            float y = 120f;
            c.drawText("Echoes wallpaper error - please screenshot this", 24f, y, errorPaint);
            for (String line : errorText.split("\n")) {
                y += 36f;
                if (y > viewH - 24f) {
                    break;
                }
                c.drawText(line.length() > 60 ? line.substring(0, 60) : line, 24f, y, errorPaint);
            }
        }

        private void render(Canvas c, float t) {
            c.drawColor(0xFF000000);
            c.save();
            c.translate(offX, offY);
            c.scale(scale, scale);

            // background plate
            c.save();
            c.translate(tiltX * DEPTH_BG, tiltY * DEPTH_BG);
            c.scale(OVERSCAN, OVERSCAN, REF_W / 2f, REF_H / 2f);
            c.drawBitmap(bg, 0f, 0f, plain);
            c.restore();

            // mist, drifting in opposite directions
            float drift = (t * MIST_SPEED) % MIST_PERIOD;
            drawMist(c, fog1, drift, 0.32f);
            drawMist(c, fog2, MIST_PERIOD - drift, 0.25f);

            // flower cutout, with the living eye drawn over its still copy
            float fx = tiltX * DEPTH_FLOWER;
            float fy = tiltY * DEPTH_FLOWER;
            c.drawBitmap(flower, fx, FLOWER_Y + fy, plain);
            buildEyeMesh(t);
            c.save();
            c.translate(fx, FLOWER_Y + fy);
            c.drawBitmapMesh(eye, MESH_W, MESH_H, eyeMesh, 0, null, 0, plain);
            c.restore();

            // eye glow pulses on a 6 second beat
            float beat = 0.5f + 0.5f * (float) Math.sin(2 * Math.PI * t / 6f);
            glow.setAlpha((int) (255 * (0.04f + 0.2f * beat * beat)));
            c.save();
            c.translate(560f + fx, 1010f + fy);
            c.drawCircle(0f, 0f, 150f, glow);
            c.restore();

            drawSpores(c, t, tiltX * DEPTH_SPORES, tiltY * DEPTH_SPORES);

            c.drawBitmap(vignette, 0f, 0f, plain);
            c.restore();
        }

        /**
         * Warps the eye crop: the pupil breathes between roughly 10 and 21 px radius and the iris
         * drifts a few pixels, as in the video. Each mesh vertex starts on a regular grid over the
         * crop and is pushed to where that part of the picture should appear.
         */
        private void buildEyeMesh(float t) {
            double tau = 2 * Math.PI;
            float pupil = PUPIL_BASE + 5f * (float) Math.sin(tau * t / 6f)
                    + 1f * (float) Math.sin(tau * t / 3f + 0.7);
            float lookX = 5f * (float) Math.sin(tau * t / 18f) + 2f * (float) Math.sin(tau * t / 9f + 1f);
            float lookY = 2f * (float) Math.sin(2 * tau * t / 18f + 2f);

            int i = 0;
            for (int row = 0; row <= MESH_H; row++) {
                float srcY = EYE_Y + row * (float) EYE_H / MESH_H;
                for (int col = 0; col <= MESH_W; col++) {
                    float srcX = EYE_X + col * (float) EYE_W / MESH_W;
                    float qx = srcX;
                    float qy = srcY;

                    float dx = srcX - PUPIL_X;
                    float dy = srcY - PUPIL_Y;
                    float r = (float) Math.sqrt(dx * dx + dy * dy);
                    if (r > 0.0001f && r < WARP_RADIUS) {
                        float rDst = r < PUPIL_BASE
                                ? r * pupil / PUPIL_BASE
                                : pupil + (r - PUPIL_BASE) * (WARP_RADIUS - pupil) / (WARP_RADIUS - PUPIL_BASE);
                        float k = rDst / r;
                        qx = PUPIL_X + dx * k;
                        qy = PUPIL_Y + dy * k;
                    }

                    float ix = qx - IRIS_X;
                    float iy = qy - IRIS_Y;
                    float w = (68f - (float) Math.sqrt(ix * ix + iy * iy)) / 18f;
                    w = Math.max(0f, Math.min(1f, w));

                    eyeMesh[i++] = qx + lookX * w;
                    eyeMesh[i++] = qy + lookY * w;
                }
            }
        }

        private void drawMist(Canvas c, Bitmap fog, float off, float alpha) {
            screen.setAlpha((int) (255 * alpha));
            c.save();
            c.translate(tiltX * DEPTH_FOG, tiltY * DEPTH_FOG);
            c.scale(OVERSCAN, OVERSCAN, REF_W / 2f, REF_H / 2f);
            // the mist art repeats every MIST_PERIOD px, so two copies cover the canvas at any offset
            c.drawBitmap(fog, off - MIST_PERIOD, 0f, screen);
            c.drawBitmap(fog, off - MIST_PERIOD + REF_W, 0f, screen);
            c.restore();
        }

        private void drawSpores(Canvas c, float t, float shiftX, float shiftY) {
            for (int i = 0; i < SPORE_COUNT; i++) {
                float u = (t / SPORE_LIFE + sph[i]) % 1f;
                float fade = (float) Math.pow(Math.sin(Math.PI * u), 1.5);
                if (fade < 0.02f) {
                    continue;
                }
                float x = sx[i] + sdx[i] * u
                        + samp[i] * (float) Math.sin(2 * Math.PI * (sk[i] * u + ssw[i])) + shiftX;
                float y = sy[i] - sdy[i] * u + shiftY;
                float r = srad[i];
                screen.setAlpha((int) (255 * Math.min(1f, sbri[i] * fade * 1.2f)));
                c.save();
                c.translate(x, y);
                c.scale(r / 32f, r / 32f);
                c.drawBitmap(sprite, -32f, -32f, screen);
                c.restore();
            }
        }
    }
}
