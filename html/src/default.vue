<template>
    <div class="container">
        <img @click="back" v-if="'start'!==currentRouteName" class="arrow-back" src="./assets/arrow.svg" alt="back" />
        <img @click="connect" v-if="'start'!==currentRouteName" class="gamepad" src="./assets/gamepad.svg" alt="gamepad" />
        <notifications />
        <router-view class="view"/>
    </div>
</template>

<script>
import * as JoyCon from "./components/joycon/index.js";
import {connectedJoyCons,JoyConLeft} from "./components/joycon";
import {leftControls,rightControls} from "@/components/control"

export default {
    name: "default.vue",
    data(){
        return {
            inputCBKS:[],
            inputDetailCBKS:[]
        }
    },
    mounted() {
        let me = this
        me.watchStatus()
    },
    computed: {
        currentRouteName() {
            return this.$route.name;
        }
    },
    provide() {
        return {
            connect: this.connect,
            addInputCBK:this.addInputCBK,
            addInputDetailCBK:this.addInputDetailCBK
        }
    },
    methods:{
        control(joyCon, packet){
            let me = this
            if (!packet || !packet.actualOrientation) {
                return;
            }
            if (joyCon instanceof JoyConLeft) {
                for (const control of leftControls) {
                    me.updateControl(control, packet);
                }
            } else {
                for (const control of rightControls) {
                    me.updateControl(control, packet);
                }
            }
        },
        updateControl (control, packet, side)  {
            let me = this
            me.lastPacket = packet;
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
            // console.log(newValue);
            if (Math.abs(newValue - control.last_value) > control.threshold) {
                // const msg = control.generate_midi(newValue);
                // if (msg !== undefined) {
                // sendMidi(msg, control.name);
                // }

                // if(!!newValue){
                //     // press
                // }else{
                //     // cancel
                // }
                let status = !!newValue?'on':'off';
                me.inputDetailCBKS.forEach((func)=>{
                    func && func(control,status)
                })
                console.log(control.name,newValue,control.last_value);
                control.last_value = newValue;
            }
        },
        async connect(){
            let me = this
            let r = await JoyCon.connectJoyCon();
            if(!!connectedJoyCons.size){
                me.$notify("Joy-Con connected");
            }
        },
        addInputCBK(func){
            let me = this;
            me.inputCBKS.push(func)
        },
        addInputDetailCBK(func){
            let me = this;
            me.inputDetailCBKS.push(func)
        },
        watchStatus(){
            let me = this
            setInterval(async () => {
                for (const joyCon of connectedJoyCons.values()) {
                    if (joyCon.eventListenerAttached) {
                        continue;
                    }
                    joyCon.eventListenerAttached = true;
                    await joyCon.disableVibration();
                    joyCon.addEventListener('hidinput', (event) => {
                        me.control(joyCon, event.detail)
                        // custom event
                        me.inputCBKS.forEach((func)=>{
                            func && func(joyCon, event.detail)
                        })
                        // me.updateBothControls(joyCon, event.detail);
                        // me.visualize(joyCon, event.detail);
                    });
                }
            }, 2000);
        },
      back(){
          let me = this
          me.$router.go(-1)
      }
    }
}
</script>

<style scoped>
    body,html{
        background: #000;
        height: 100%;
    }
    .container{
        width: 100%;
        min-height: 100vh;
        font-family: "Source Code Pro", monospace;
        background: #000;
        color:#fff;
    }
    .arrow-back{
        transform: rotate(90deg);
        width: 20px;
        position: absolute;
        top:10px;
        left:10px;
        fill: #FFFFFF;
        z-index:10;
        cursor: pointer;
    }
    .gamepad{
        width: 30px;
        position: absolute;
        top:10px;
        left:50px;
        fill: #FFFFFF;
        z-index:10;
        cursor: pointer;
    }
</style>
