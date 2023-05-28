<template>
    <div class="container">
        <div class="sub-container clearfix">
            <!--    <div>-->
            <!--        <input id="show-visualize" type="checkbox" checked="true" />-->
            <!--        <label for="show-visualize">Visualize Joycons</label>-->
            <!--        <input id="show-debug" type="checkbox" />-->
            <!--        <label for="show-debug">Show debug info</label>-->
            <!--    </div>-->
            <h1 class="container-title">Custom Hotkeys</h1>
            <div class="left-container">
                <h2 class="form-title center">Left Controller</h2>
                <form class="pure-form pure-form-aligned center">
                    <fieldset>
                        <div class="pure-control-group">
                            <label for="aligned-name">Up</label>
                            <select class="custom-select select" v-model="form.Up">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Down</label>
                            <select class="custom-select select" v-model="form.Down">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Left</label>
                            <select class="custom-select select" v-model="form.Left">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Right</label>
                            <select class="custom-select select" v-model="form.Right">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">L</label>
                            <select class="custom-select select" v-model="form.L">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">ZL</label>
                            <select class="custom-select select" v-model="form.ZL">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Twist</label>
                            <select class="custom-select select" v-model="form.LeftTwist">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Shake</label>
                            <select class="custom-select select" v-model="form.LeftShake">
                                <option v-for="item in leftOperations">{{item}}</option>
                            </select>
                        </div>
                    </fieldset>
                </form>
            </div>
            <figure class="joycon-view">
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
            <div class="right-container">
                <h2 class="form-title center">Right Controller</h2>
                <form class="pure-form pure-form-aligned center">
                    <fieldset>

                        <div class="pure-control-group">
                            <label for="aligned-name">A</label>
                            <select class="custom-select select" v-model="form.A">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">B</label>
                            <select class="custom-select select" v-model="form.B">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">X</label>
                            <select class="custom-select select" v-model="form.X">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Y</label>
                            <select class="custom-select select" v-model="form.Y">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">R</label>
                            <select class="custom-select select" v-model="form.R">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">ZR</label>
                            <select class="custom-select select" v-model="form.ZR">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Twist</label>
                            <select class="custom-select select" v-model="form.RightTwist">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                        <div class="pure-control-group">
                            <label for="aligned-name">Shake</label>
                            <select class="custom-select select" v-model="form.RightShake">
                                <option v-for="item in noteOptions">{{item}}</option>
                            </select>
                        </div>
                    </fieldset>
                </form>
            </div>
            <button class="pure-button submit" @click="submit">Submit</button>
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
        </div>

    </div>
</template>

<script>
import {connectJoyCon, connectedJoyCons, JoyConLeft} from '../components/joycon';
import {noteOptions,leftOperations,defaultHotkeys} from '../components/hotkey';
export default {
    name: "start.vue",
    data(){
        return {
            noteOptions,
            leftOperations,
            form:{
                ...defaultHotkeys
            }
        }
    },
    mounted() {
        let me = this
        me.refreshConfig()
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
    },
    methods:{
        refreshConfig(){
            let me = this
            me.form = me.$utils.readConfig()
        },
        submit(){
            let me = this
            me.$utils.save2Storage(me.form)
            me.$notify("Save Succeed");
        }
    }
}


</script>

<style lang="less" scoped>
@import "./start/joycon.css";
.container {
    position: relative;
    /*top:20px;*/
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
.sub-container{
    /*display: inline-block;*/
    width: 900px;
    padding: 30px;
    margin:30px auto;
    border:1px solid white;
}

.container ol {
    padding-inline-start: 22px;
}

.container{
    position: relative;
    padding: 20px;
    /*top:60px;*/
}
.container-title{
    text-align: center;
    margin-bottom: 30px;
}
input{
    border-color:#fff;
}
.center{
    text-align: center;
}
.custom-select{
    color: black;
}
.joycon-view{
    width: 250px;
    margin: 0 0 0 20px;
    height: auto;
}
.clearfix::after {
    content: "";
    clear: both;
    display: table;
}
.left-container,.joycon-view,.right-container{
    float: left;
}
.left-container{
    display: inline-block;
    .select{
        width: 300px;
    }
}
.right-container{
    /*width: 270px;*/
    display: inline-block;
}
.select{
    width: 120px;
}
.txt-left{
    text-align: left;
}
.txt-right{
    text-align: right;
}
.pure-form-aligned .pure-control-group label{
    width: 3em;
}
.submit{
    display: block;
    width: 90px;
    position: relative;
    left: 470px;
}
</style>
