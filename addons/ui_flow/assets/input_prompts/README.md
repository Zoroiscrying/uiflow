# Input prompt textures (Kenney CC0)

Vendored subset of [Kenney Input Prompts](https://kenney.nl/assets/input-prompts)
(CC0 1.0). Attribution appreciated but not required: Kenney.nl.

| File | Use |
|---|---|
| `xbox_a/b/x/y.png` | Gamepad face buttons |
| `xbox_dpad.png` | D-Pad |
| `xbox_stick_l.png` | Left stick |
| `kb_e/esc/enter/space/f1.png` | Common keyboard keys |
| `kb_up/down/left/right.png` | Arrow keys |

Shoulder / tab glyphs (`tab_prev` / `tab_next`) currently use text badges
(`LB`/`RB`, `[`/`]`) until Kenney LB/RB assets are vendored.

Load via `UIFlowInputPromptIcons.texture_for(&"interact")` or
`UIFlowInputPrompt.make_semantic(&"interact", "Open")`.

`UIFlow.InputDevice` picks keyboard vs gamepad glyphs from the last input used.
