import csv,statistics as st,sys
D=sys.argv[1]
def load(l): return [r for r in csv.DictReader(open(f"{D}/{l}.csv"))]
sets={l:load(l) for l in ['duel6','ttk6','duel12','ttk12']}
heroes=sorted({r['player'] for r in sets['duel6']})
def ttk_player(rows,h):
    a=[r for r in rows if r['player']==h]; w=[int(r['turns']) for r in a if r['result']=='win']
    return (st.mean(w) if w else 99, 100*len(w)/len(a))
def ttk_rival(rows,h):
    a=[r for r in rows if r['rival']==h]; w=[int(r['turns']) for r in a if r['result']=='win']
    return (st.mean(w) if w else 99, 100*len(w)/len(a))
def duel_player(rows,h):
    a=[r for r in rows if r['player']==h]; return 100*sum(r['result']=='win' for r in a)/len(a)
def duel_rival(rows,h):  # rival wins = player loss
    a=[r for r in rows if r['rival']==h]; return 100*sum(r['result']=='loss' for r in a)/len(a)
def rival_kill_turns(rows,h):
    a=[int(r['turns']) for r in rows if r['rival']==h and r['result']=='loss']; return st.mean(a) if a else 0
print("PLAYER-SIDE POWER  (15 hero x 14 rivals each)")
print("%-22s| L6: duel win%% | turns to kill rival | L12: duel win%% | turns to kill rival"%"hero")
for h in sorted(heroes,key=lambda h:-(duel_player(sets['duel6'],h)+duel_player(sets['duel12'],h))):
    print("%-22s|  %4.0f%%        |   %5.1f            |   %4.0f%%        |   %5.1f"%(h,duel_player(sets['duel6'],h),ttk_player(sets['ttk6'],h)[0],duel_player(sets['duel12'],h),ttk_player(sets['ttk12'],h)[0]))
print()
print("RIVAL-SIDE DIFFICULTY (as the boss)")
print("%-22s| L6: beats you%% | turns to kill you | turns you need | L12: beats you%% | turns to kill you | turns you need"%"hero")
for h in sorted(heroes,key=lambda h:-(duel_rival(sets['duel6'],h)+duel_rival(sets['duel12'],h))):
    print("%-22s|  %4.0f%%         |   %5.1f           |   %5.1f        |   %4.0f%%         |   %5.1f           |   %5.1f"%(h,duel_rival(sets['duel6'],h),rival_kill_turns(sets['duel6'],h),ttk_rival(sets['ttk6'],h)[0],duel_rival(sets['duel12'],h),rival_kill_turns(sets['duel12'],h),ttk_rival(sets['ttk12'],h)[0]))
