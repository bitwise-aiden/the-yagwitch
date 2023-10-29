# trijam243
A game made for Trijam #243 (https://itch.io/jam/trijam-243)

**Theme:** Cursed Relic

## Planning

Talking with Yag, she mentioned that she once made a game for Trijam where you had to type messages while some keys on the keyboard weren't working. This gave me some inspiration for this jam in that an old PC is considered a relic, and what if it were cursed by some kind of spirit?

This looks like a game where a cursed PC is asking you to repeat after them but certain keys on the keyboard have disappeared, or the mouse buttons have been removed. It is a kind of puzzle game where you have to use the keys you have available or scroll back through your history, highlighting letters and words to copy/paste.

Aesthetically the game will start with a retro looking computer screen with keyboard and mouse sat in front of it. There is a white cursor blinking in the middle of the screen. It will use crude drawings done in Aseprite with a CRT shader on the display and dithering lighting + bloom coming off the screen.

When a player presses any key, the prompt will then type out "What is your name?" letting the player insert a name up to 26 characters long. Once they hit enter it will then flash and the text turns a glowing purple and the spirit reveals itself. It will then explain that to get control of their computer back they must repeat each of the messages that are presented to them.

Messages will be retained and they can be scrolled through like a chat log. As the levels progress the puzzles will get more difficult with less keys and sometimes the history will be cleared entirely.

The player will have a small countdown that when lost the player loses a life. They will have 3 lives otherwise they will lose the game.

## TODO

- [ ] Graphics
    - [ ] Computer monitor / base
    - [ ] Keyboard
        - [ ] Chasis
        - [ ] Keys (a-z, 0-9, space)
    - [ ] Mouse
        - [ ] Chasis
        - [ ] Buttons (left, middle, right)
    - [ ] Shaders
        - [ ] Bloom
        - [ ] CRT
        - [ ] Dithering / lighting
- [ ] Mechanics
    - [ ] Start screen
    - [ ] Enter name
    - [ ] Chat
        - [ ] Display messages
            - [ ] Player
            - [ ] Spirit
            - [ ] Active message
        - [ ] Type messages
            - [ ] Keyboard with active buttons
            - [ ] Paste keyboard
            - [ ] Paste mouse
            - [ ] Countdown for failure
                - [ ] Lose life on countdown lost - Trigger fail
        - [ ] Send messages
            - [ ] Check message is the same as active message
                - [ ] Success on same - Continues through challenges
                - [ ] Fail on not - Scorns and repeats active message as new message
                    - [ ] Clears previous version of active message so it can't be copied
                    - [ ] Don't lose life when message is wrong
        - [ ] Highlight text
            - [ ] Copy keyboard
            - [ ] Copy mouse
        - [ ] Prevent last message from being copied
            - [ ] Last message glows
    - [ ] Keyboard / mouse management
        - [ ] Keys glowing
        - [ ] Keys / Buttons disappearing
    - [ ] Lives
        - [ ] Lose game when lives lost
        - [ ] Gain life when spirit is pleased
- [ ] Puzzles
    - [ ] Typing with keys currently active
    - [ ] Highlighting and copying previous text
    - [ ] Intentionally failing message to get more characters
    - [ ] Intentionally losing life to get more characters
