# Sequences

One file per sequence. A sequence is written against a **signal**, for one ICP, on named channels,
with a stop rule. The skeleton:

```
# <sequence name>
signal:     <which signal from ../signals.md>
icp:        <who, in one line, from memory/branches/gtm/icp.md>
channels:   <in order>
window:     <days from first touch to close-the-loop>
stop:       any reply | any no | unsubscribe | 5 touches

## Observation bank
1. <specific fact about this segment that proves a human looked>
2. ...

## Touches
1. <channel> — <the message, as it would be sent>
2. ...

## Measurement
reply rate / positive reply rate / meeting rate / opt-out rate — recorded in ../metrics.md
```

Empty files are honest. A sequence with invented prospects is not.
