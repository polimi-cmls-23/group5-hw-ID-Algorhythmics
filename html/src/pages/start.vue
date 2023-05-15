<template>
    <div class="container">
        <!--    <div>-->
        <!--        <input id="show-visualize" type="checkbox" checked="true" />-->
        <!--        <label for="show-visualize">Visualize Joycons</label>-->
        <!--        <input id="show-debug" type="checkbox" />-->
        <!--        <label for="show-debug">Show debug info</label>-->
        <!--    </div>-->
        <h1 class="container-title">Visualization</h1>
        <figure>
            <div id="joycon-l" class="joycon productId8198">
                <div id="joystick-left" class="joystick"></div>
                <div class="buttons">
                    <button id="up"></button>
                    <button id="left"></button>
                    <button id="down"></button>
                    <button id="right"></button>
                </div>
                <span id="minus"></span>
                <i id="capture"></i>
                <strong class="back-buttons" id="l"></strong>
            </div>
            <div id="joycon-r" class="joycon productId8199">
                <div id="joystick-right" class="joystick"></div>
                <div class="buttons">
                    <button id="x"></button>
                    <button id="y"></button>
                    <button id="b"></button>
                    <button id="a"></button>
                </div>
                <span id="plus"></span>
                <i id="home"></i>
                <strong class="back-buttons" id="r"></strong>
            </div>
        </figure>
        <div id="debug">
            <div id="debug-left">
                <pre></pre>
                <p>Acceleration</p>
                <meter id="acc-x" min="-1" max="1"></meter>
                <meter id="acc-y" min="-1" max="1"></meter>
                <meter id="acc-z" min="-1" max="1"></meter>
                <br/>
                <p>Gyroscope</p>
                <meter id="gyr-x" min="-1" max="1"></meter>
                <meter id="gyr-y" min="-1" max="1"></meter>
                <meter id="gyr-z" min="-1" max="1"></meter>
            </div>

            <div id="debug-right">
                <pre></pre>
                <p>Acceleration</p>
                <meter id="acc-x" min="-1" max="1"></meter>
                <meter id="acc-y" min="-1" max="1"></meter>
                <meter id="acc-z" min="-1" max="1"></meter>
                <br/>
                <p>Gyroscope</p>
                <meter id="gyr-x" min="-1" max="1"></meter>
                <meter id="gyr-y" min="-1" max="1"></meter>
                <meter id="gyr-z" min="-1" max="1"></meter>
            </div>
        </div>
        <div>
            <h1 class="container-title">Custom Keymap</h1>
            <p>Message is: {{ form.A }}</p>
            <input v-model="form.A" placeholder="edit me" />
        </div>
    </div>
</template>

<script>
import {connectJoyCon, connectedJoyCons, JoyConLeft} from '../components/joycon';

export default {
    name: "start.vue",
    data(){
        return {
            form:{
                A:''
            }
        }
    },
    mounted() {

        const debugLeft = document.querySelector('#debug-left');
        const debugRight = document.querySelector('#debug-right');
        const showVisualize = document.querySelector('#show-visualize');
        const showDebug = document.querySelector('#show-debug');
        const rootStyle = document.querySelector('.container').style;
        let midiout = null;

        const sendMidi = (bytes, msg = '') => {
            if (midiout) {
                console.log(bytes + ' ' + msg);
                midiout.send(bytes);
            } else {
                console.log('MIDI not connected');
            }
        };

        const MIDI_NOTE_ON_CH_1 = 0x90;
        const MIDI_NOTE_OFF_CH_1 = 0x80;
        const MIDI_VELOCITY_MAX = 0x7f;
        const MIDI_VELOCITY_MIN = 0;
        const MIDI_CC_CH_1 = 0xb0;

        // Returns a function that converts a boolean value to a note-on or note-off
        // message.
        const noteOnOff = (note) => {
            return (readValue) => [
                readValue ? MIDI_NOTE_ON_CH_1 : MIDI_NOTE_OFF_CH_1,
                note,
                MIDI_VELOCITY_MAX,
            ];
        };

        // Returns a function that converts a boolean value to a CC message.
        const buttonCCForControl = (control) => {
            return (readValue) => [
                MIDI_CC_CH_1,
                control,
                readValue ? MIDI_VELOCITY_MAX : MIDI_VELOCITY_MIN,
            ];
        };

        // Returns a function that convents a float in the range 0-1 to a CC message.
        const analogCCForControl = (control) => {
            return (readValue) => [
                MIDI_CC_CH_1,
                control,
                Math.max(
                    Math.min(Math.round(127 * readValue), MIDI_VELOCITY_MAX),
                    MIDI_VELOCITY_MIN
                ),
            ];
        };

        const leftControls = [
            // Define buttons first since they're latency critical and the updates are
            // rarer.
            {
                name: 'down-button',
                read_value: (packet) => packet.buttonStatus.down,
                generate_midi: noteOnOff(0x24),
            },
            {
                name: 'right-button',
                read_value: (packet) => packet.buttonStatus.right,
                generate_midi: noteOnOff(0x25),
            },
            {
                name: 'up-button',
                read_value: (packet) => packet.buttonStatus.up,
                generate_midi: noteOnOff(0x26),
            },
            {
                name: 'left-button',
                read_value: (packet) => packet.buttonStatus.left,
                generate_midi: noteOnOff(0x27),
            },
            {
                name: 'l-button',
                read_value: (packet) => packet.buttonStatus.l,
                generate_midi: noteOnOff(0x28),
            },
            {
                name: 'zl-button',
                read_value: (packet) => packet.buttonStatus.zl,
                generate_midi: noteOnOff(0x29),
            },
            {
                name: 'capture-button-as-note',
                read_value: (packet) => packet.buttonStatus.capture,
                generate_midi: noteOnOff(0x2a),
            },
            {
                name: 'minus-button-as-note',
                read_value: (packet) => packet.buttonStatus.minus,
                generate_midi: noteOnOff(0x2b),
            },

            // Control (CC) buttons
            {
                name: 'minus-button-as-cc',
                read_value: (packet) => packet.buttonStatus.minus,
                generate_midi: buttonCCForControl(0x01),
            },
            {
                name: 'capture-button-as-cc',
                read_value: (packet) => packet.buttonStatus.capture,
                generate_midi: buttonCCForControl(0x02),
            },
            {
                name: 'l-sl-button',
                read_value: (packet) => packet.buttonStatus.sl,
                generate_midi: buttonCCForControl(0x03),
            },
            {
                name: 'l-sr-button',
                read_value: (packet) => packet.buttonStatus.sr,
                generate_midi: buttonCCForControl(0x04),
            },
            {
                name: 'l-stick',
                read_value: (packet) => packet.buttonStatus.leftStick,
                generate_midi: buttonCCForControl(0x05),
            },

            // Analog controls (CC)
            {
                name: 'l-orientation.beta',
                read_value: (packet) =>
                    (Number(packet.actualOrientation.beta) + 90.0) / 180.0,
                generate_midi: analogCCForControl(0x0b),
                threshold: 3 / 180.0,
            },
            {
                name: 'l-orientation.gamma',
                read_value: (packet) =>
                    (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
                generate_midi: analogCCForControl(0x0c),
                threshold: 3 / 180.0,
            },
            {
                name: 'l-analog-horizontal',
                read_value: (packet) => {
                    const hmin = -1.2;
                    const hmax = 1.4;
                    return (
                        (Math.max(
                                hmin,
                                Math.min(Number(packet.analogStickLeft.horizontal), hmax)
                            ) -
                            hmin) /
                        (hmax - hmin)
                    );
                },
                generate_midi: analogCCForControl(0x0d),
                threshold: 0.02,
            },
            {
                name: 'l-analog-vertical',
                read_value: (packet) => {
                    const vmin = -0.7;
                    const vmax = 0.9;
                    return (
                        (Math.max(
                                vmin,
                                Math.min(Number(packet.analogStickLeft.vertical), vmax)
                            ) -
                            vmin) /
                        (vmax - vmin)
                    );
                },
                generate_midi: analogCCForControl(0x0e),
                threshold: 0.02,
            },
        ];

        const rightControls = [
            // Define buttons first since they're latency critical and the updates are
            // rarer.
            {
                name: 'b-button',
                read_value: (packet) => packet.buttonStatus.b,
                generate_midi: noteOnOff(0x2c),
            },
            {
                name: 'a-button',
                read_value: (packet) => packet.buttonStatus.a,
                generate_midi: noteOnOff(0x2d),
            },
            {
                name: 'x-button',
                read_value: (packet) => packet.buttonStatus.x,
                generate_midi: noteOnOff(0x2e),
            },
            {
                name: 'y-button',
                read_value: (packet) => packet.buttonStatus.y,
                generate_midi: noteOnOff(0x2f),
            },
            {
                name: 'r-button',
                read_value: (packet) => packet.buttonStatus.r,
                generate_midi: noteOnOff(0x30),
            },
            {
                name: 'zr-button',
                read_value: (packet) => packet.buttonStatus.zr,
                generate_midi: noteOnOff(0x31),
            },
            {
                name: 'home-button-as-note',
                read_value: (packet) => packet.buttonStatus.home,
                generate_midi: noteOnOff(0x32),
            },
            {
                name: 'plus-button-as-note',
                read_value: (packet) => packet.buttonStatus.plus,
                generate_midi: noteOnOff(0x33),
            },

            // Control (CC) buttons
            {
                name: 'plus-button-as-cc',
                read_value: (packet) => packet.buttonStatus.plus,
                generate_midi: buttonCCForControl(0x06),
            },
            {
                name: 'home-button-as-cc',
                read_value: (packet) => packet.buttonStatus.home,
                generate_midi: buttonCCForControl(0x07),
            },
            {
                name: 'sr-button',
                read_value: (packet) => packet.buttonStatus.sr,
                generate_midi: buttonCCForControl(0x08),
            },
            {
                name: 'sl-button',
                read_value: (packet) => packet.buttonStatus.sl,
                generate_midi: buttonCCForControl(0x09),
            },
            {
                name: 'r-stick',
                read_value: (packet) => packet.buttonStatus.rightStick,
                generate_midi: buttonCCForControl(0x0a),
            },

            // Analog controls (CC)
            {
                name: 'orientation.beta',
                read_value: (packet) =>
                    (Number(packet.actualOrientation.beta) + 90.0) / 180.0,
                generate_midi: analogCCForControl(0x0f),
                threshold: 3 / 180.0,
            },
            {
                name: 'orientation.gamma',
                read_value: (packet) =>
                    (Number(packet.actualOrientation.gamma) + 90.0) / 180.0,
                generate_midi: analogCCForControl(0x10),
                threshold: 3 / 180.0,
            },
            {
                name: 'r-analog-horizontal',
                read_value: (packet) => {
                    const hmin = -1.2;
                    const hmax = 1.4;
                    return (
                        (Math.max(
                                hmin,
                                Math.min(Number(packet.analogStickRight.horizontal), hmax)
                            ) -
                            hmin) /
                        (hmax - hmin)
                    );
                },
                generate_midi: analogCCForControl(0x11),
                threshold: 0.02,
            },
            {
                name: 'r-analog-vertical',
                read_value: (packet) => {
                    const vmin = -0.7;
                    const vmax = 1.4;
                    return (
                        (Math.max(
                                vmin,
                                Math.min(Number(packet.analogStickRight.vertical), vmax)
                            ) -
                            vmin) /
                        (vmax - vmin)
                    );
                },
                generate_midi: analogCCForControl(0x12),
                threshold: 0.02,
            },
        ];

        const updateControl = (control, packet, side) => {
            window.lastPacket = packet;
            if (control.threshold === undefined) {
                control.threshold = 0;
            }
            if (control.last_value === undefined) {
                if (control.init_value === undefined) {
                    control.init_value = 0;
                }
                control.last_value = control.init_value;
            }
            const newValue = control.read_value(packet);
            if (Math.abs(newValue - control.last_value) > control.threshold) {
                const msg = control.generate_midi(newValue);
                if (msg !== undefined) {
                    sendMidi(msg, control.name);
                }
                control.last_value = newValue;
            }
        };

        const updateBothControls = (joyCon, packet) => {
            if (!packet || !packet.actualOrientation) {
                return;
            }
            if (joyCon instanceof JoyConLeft) {
                for (const control of leftControls) {
                    updateControl(control, packet);
                }
            } else {
                for (const control of rightControls) {
                    updateControl(control, packet);
                }
            }
        };

        const visualize = (joyCon, packet) => {
            if (!packet || !packet.actualOrientation) {
                return;
            }

            const {
                actualAccelerometer: accelerometer,
                buttonStatus: buttons,
                actualGyroscope: gyroscope,
                actualOrientation: orientation,
                actualOrientationQuaternion: orientationQuaternion,
            } = packet;

            if (joyCon instanceof JoyConLeft) {
                rootStyle.setProperty('--left-alpha', `${orientation.alpha}deg`);
                rootStyle.setProperty('--left-beta', `${orientation.beta}deg`);
                rootStyle.setProperty('--left-gamma', `${orientation.gamma}deg`);
            } else {
                rootStyle.setProperty('--right-alpha', `${orientation.alpha}deg`);
                rootStyle.setProperty('--right-beta', `${orientation.beta}deg`);
                rootStyle.setProperty('--right-gamma', `${orientation.gamma}deg`);
            }

            if (joyCon instanceof JoyConLeft) {
                const joystick = packet.analogStickLeft;
                const joystickMultiplier = 10;
                document.querySelector('#joystick-left').style.transform = `translateX(${
                    joystick.horizontal * joystickMultiplier
                }px) translateY(${joystick.vertical * joystickMultiplier}px)`;

                document.querySelector('#up').classList.toggle('highlight', buttons.up);
                document
                    .querySelector('#down')
                    .classList.toggle('highlight', buttons.down);
                document
                    .querySelector('#left')
                    .classList.toggle('highlight', buttons.left);
                document
                    .querySelector('#right')
                    .classList.toggle('highlight', buttons.right);
                document
                    .querySelector('#capture')
                    .classList.toggle('highlight', buttons.capture);
                document
                    .querySelector('#l')
                    .classList.toggle('highlight', buttons.l || buttons.zl);
                document
                    .querySelector('#l')
                    .classList.toggle('highlight', buttons.l || buttons.zl);
                document
                    .querySelector('#minus')
                    .classList.toggle('highlight', buttons.minus);
                document
                    .querySelector('#joystick-left')
                    .classList.toggle('highlight', buttons.leftStick);
            } else {
                const joystick = packet.analogStickRight;
                const joystickMultiplier = 10;
                document.querySelector('#joystick-right').style.transform = `translateX(${
                    joystick.horizontal * joystickMultiplier
                }px) translateY(${joystick.vertical * joystickMultiplier}px)`;

                document.querySelector('#a').classList.toggle('highlight', buttons.a);
                document.querySelector('#b').classList.toggle('highlight', buttons.b);
                document.querySelector('#x').classList.toggle('highlight', buttons.x);
                document.querySelector('#y').classList.toggle('highlight', buttons.y);
                document
                    .querySelector('#home')
                    .classList.toggle('highlight', buttons.home);
                document
                    .querySelector('#r')
                    .classList.toggle('highlight', buttons.r || buttons.zr);
                document
                    .querySelector('#r')
                    .classList.toggle('highlight', buttons.r || buttons.zr);
                document
                    .querySelector('#plus')
                    .classList.toggle('highlight', buttons.plus);
                document
                    .querySelector('#joystick-right')
                    .classList.toggle('highlight', buttons.rightStick);
            }

            // if (showDebug.checked) {
            //     const controller = joyCon instanceof JoyConLeft ? debugLeft : debugRight;
            //     controller.querySelector('pre').textContent =
            //         JSON.stringify(orientation, null, 2) +
            //         '\n' +
            //         JSON.stringify(orientationQuaternion, null, 2) +
            //         '\n' +
            //         JSON.stringify(gyroscope, null, 2) +
            //         '\n' +
            //         JSON.stringify(accelerometer, null, 2) +
            //         '\n';
            //     const meterMultiplier = 300;
            //     controller.querySelector('#acc-x').value =
            //         accelerometer.x * meterMultiplier;
            //     controller.querySelector('#acc-y').value =
            //         accelerometer.y * meterMultiplier;
            //     controller.querySelector('#acc-z').value =
            //         accelerometer.z * meterMultiplier;
            //
            //     const gyroscopeMultiplier = 300;
            //     controller.querySelector('#gyr-x').value =
            //         gyroscope.rps.x * gyroscopeMultiplier;
            //     controller.querySelector('#gyr-y').value =
            //         gyroscope.rps.y * gyroscopeMultiplier;
            //     controller.querySelector('#gyr-z').value =
            //         gyroscope.rps.z * gyroscopeMultiplier;
            // }
        };

        // Joy-Cons may sleep until touched, so attach the listener dynamically.
        setInterval(async () => {
            for (const joyCon of connectedJoyCons.values()) {
                if (joyCon.eventListenerAttached) {
                    continue;
                }
                joyCon.eventListenerAttached = true;
                await joyCon.disableVibration();
                joyCon.addEventListener('hidinput', (event) => {
                    updateBothControls(joyCon, event.detail);
                    visualize(joyCon, event.detail);
                });
            }
        }, 2000);

        // showDebug.addEventListener('input', (e) => {
        //     document.querySelector('#debug').style.display = e.target.checked
        //         ? 'flex'
        //         : 'none';
        // });
    }
}


</script>

<style scoped>
.container {
    color-scheme: dark light;
    --left-alpha: 0deg;
    --left-beta: 0deg;
    --left-gamma: 0deg;
    --right-alpha: 0deg;
    --right-beta: 0deg;
    --right-gamma: 0deg;
    --left-joy-con-color: #00b2dc;
    --right-joy-con-color: #ff493e;
}

.container ol {
    padding-inline-start: 22px;
}

.container a {
    color: var(--right-joy-con-color);
}

ul {
    list-style-type: none;
    margin: 0;
}

.joycon.rumble {
    animation: shake 0.2s cubic-bezier(0.36, 0.07, 0.19, 0.97) both;
    transform: translate3d(0, 0, 0);
}

@keyframes shake {
    10%,
    90% {
        transform: translate3d(-1px, 0, 0);
    }

    20%,
    80% {
        transform: translate3d(2px, 0, 0);
    }

    30%,
    50%,
    70% {
        transform: translate3d(-4px, 0, 0);
    }

    40%,
    60% {
        transform: translate3d(4px, 0, 0);
    }
}

#debug {
    display: none;
    gap: 50px;
}

#left.highlight,
#right.highlight,
#up.highlight,
#down.highlight,
#capture.highlight,
#minus.highlight,
#joycon-l .highlight {
    outline: solid 2px var(--right-joy-con-color);
}

#l.highlight:after {
    border-left-color: var(--right-joy-con-color);
}

#x.highlight,
#y.highlight,
#a.highlight,
#b.highlight,
#home.highlight,
#plus.highlight,
#joycon-r .highlight {
    outline: solid 2px;
}

#r.highlight:after {
    border-left-color: var(--left-joy-con-color);
}

figure {
    perspective: 1000px;
}

#joycon-l {
    transform-style: preserve-3d;
    transform: rotateZ(var(--left-alpha)) rotateX(var(--left-beta)) rotateY(var(--left-gamma));
}

#joycon-r {
    transform-style: preserve-3d;
    transform: rotateZ(var(--right-alpha)) rotateX(var(--right-beta)) rotateY(var(--right-gamma));
}

[data-z] {
    transform: rotateX(15deg) rotateY(-30deg);
}

.joycon {
    width: 75px;
    height: 220px;
    display: inline-block;
    margin: 0 25px;
    border-top: 5px solid rgba(255, 255, 255, 0.4);
    border-bottom: 10px solid rgba(0, 0, 0, 0.1);
    position: relative;
}

.joycon:nth-child(1) {
    background-color: #00b2dc;
    border-top-left-radius: 50px;
    border-bottom-left-radius: 50px;
}

.joycon:nth-child(2) {
    background-color: #ff493e;
    border-top-right-radius: 50px;
    border-bottom-right-radius: 50px;
}

/* Joysticks */
.joystick {
    width: 35px;
    height: 35px;
    background: linear-gradient(to top right, #333, #60686b);
    border-radius: 50%;
    border: 2px solid rgba(0, 0, 0, 0.4);
    box-sizing: border-box;
    box-shadow: 0px 3px 0px rgba(0, 0, 0, 0.3);
    position: absolute;
}

.joystick:after {
    content: '';
    width: 27px;
    height: 27px;
    position: absolute;
    border: 1px solid rgba(0, 0, 0, 0.8);
    border-radius: 50%;
    box-sizing: border-box;
    transform: translate(-50%, -50%);
    top: 50%;
    left: 50%;
}

.joycon:nth-child(1) .joystick {
    top: 40px;
    left: 20px;
}

.joycon:nth-child(2) .joystick {
    top: 110px;
    left: 20px;
}

/* Buttons */
.buttons {
    width: 55px;
    height: 55px;
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
}

.joycon button {
    font-family: Arial;
    width: 17px;
    height: 17px;
    border-radius: 50%;
    position: absolute;
    border: none;
    text-align: center;
    background: linear-gradient(to top right, #222, #666);
    padding: 0;
    border: 1px solid rgba(0, 0, 0, 0.3);
    box-shadow: 0px 0px 2px rgba(0, 0, 0, 0.8);
    box-sizing: border-box;
    font-size: 8pt;
}

.joycon:nth-child(1) .buttons {
    top: 100px;
}

.joycon:nth-child(2) .buttons {
    top: 30px;
}

.joycon:nth-child(1) button {
    color: #252525;
}

.joycon:nth-child(2) button {
    color: #bbb;
}

.joycon button:nth-child(1) {
    left: 19px;
}

.joycon button:nth-child(2) {
    top: 19px;
}

.joycon button:nth-child(3) {
    left: 19px;
    bottom: 0;
}

.joycon button:nth-child(4) {
    top: 19px;
    right: 0;
}

.joycon button:before {
    content: '';
    width: 100%;
    height: 100%;
    border-top: 2px solid rgba(255, 255, 255, 0.3);
    transform: rotate(40deg);
    border-radius: 50%;
    position: absolute;
    left: 0;
    top: 0;
}

.joycon:nth-child(1) button:nth-child(1):after {
    content: '▲';
}

.joycon:nth-child(1) button:nth-child(2):after {
    content: '◀';
}

.joycon:nth-child(1) button:nth-child(3):after {
    content: '▼';
}

.joycon:nth-child(1) button:nth-child(4):after {
    content: '►';
}

.joycon:nth-child(2) button:nth-child(1):after {
    content: 'X';
}

.joycon:nth-child(2) button:nth-child(2):after {
    content: 'Y';
}

.joycon:nth-child(2) button:nth-child(3):after {
    content: 'B';
}

.joycon:nth-child(2) button:nth-child(4):after {
    content: 'A';
}

button:active {
    box-shadow: none;
}

button:focus {
    outline: 0;
}

/* Start & Select */
.joycon span {
    position: absolute;
    top: 15px;
    width: 13px;
    height: 4px;
    background: #333;
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.4);
}

.joycon:nth-child(1) span {
    right: 8px;
}

.joycon:nth-child(2) span {
    left: 8px;
}

.joycon:nth-child(2) span:after {
    content: '';
    width: 4px;
    height: 13px;
    background: #333;
    transform: translateX(-50%);
    position: absolute;
    left: 50%;
    top: -4px;
    box-shadow: 0px 1px 1px rgba(0, 0, 0, 0.4);
}

/* Sliders */
.joycon:before {
    content: '';
    width: 5px;
    height: 90%;
    background: #333;
    position: absolute;
    top: 6%;
}

.joycon:nth-child(1):before {
    right: -5px;
}

.joycon:nth-child(2):before {
    left: -5px;
}

/* Triggers */
.back-buttons:after {
    content: '';
    position: absolute;
    width: 140px;
    height: 90px;
    border-radius: 50px;
    border: 4px solid transparent;
    border-left: 4px solid #333;
}

.joycon:nth-child(1) .back-buttons:after {
    transform: rotate(45deg);
    top: 10px;
    left: -10px;
}

.joycon:nth-child(2) .back-buttons:after {
    transform: rotate(140deg);
    top: 8px;
    right: -7.5px;
}

/* Home & Capture */
.joycon i {
    width: 15px;
    height: 15px;
    background: #333;
    position: absolute;
    top: 170px;
}

.joycon:nth-child(1) i {
    right: 15px;
    border-radius: 2px;
}

.joycon:nth-child(1) i:after {
    content: '';
    width: 65%;
    height: 65%;
    position: absolute;
    left: 50%;
    top: 50%;
    transform: translate(-50%, -50%);
    border-radius: 50%;
    border-top: 1px solid rgba(0, 0, 0, 0.6);
    border-bottom: 1px solid rgba(255, 255, 255, 0.3);
    box-sizing: border-box;
}

.joycon:nth-child(2) i {
    left: 15px;
    border-radius: 50%;
    border: 2px solid rgba(255, 255, 255, 0.3);
    margin: -3px;
    box-shadow: 0px 0px 1px #000;
}

figure {
    margin: 0;
    transform: translate(-50%, 0);
    position: absolute;
    left: 50%;
    /*top: 50%;*/
    height: auto;
}

.container{
    position: relative;
    padding: 30px;
    /*top:60px;*/
}
.container-title{
    text-align: center;
    margin-bottom: 30px;
}
input{
    border-color:#fff;
}
</style>
