# PISTON DEFENSE
Minimalist assembly game for a Ben Eater style breadboard 6502 driven computer

Ben Eater's 6502 kit: https://eater.net/6502

Video demo of v0.1:

# GAMEPLAY:

- You must crush a leftward projectile before it reaches the left edge of the 2x16 LCD screen.
- Push the first button to crush the projectile with your piston at the right moment.
- Push the second button to retract the piston up.

If the projectile reaches the piston when it is already in its lowered state, your piston breaks and you lose.

If the projectile reaches the left edge of the screen, you lose.

If you crush the projectile, your piston bounces back up and a new projectile is spawned.

You win by crushing a personally satisfying amount of projectile before you end the game yourself.

# TO DO:

- Make the splash screen read and display strings from the end of the ROM instead of direct instructions
- Keep score
- Retune the game using an oscillator crystal in the MHz ranger rather than a clock timer in the kHz range
- Make the following enemies increase speed
- Give the player multiple pistons that can independantly break
- Create new types of enemies
