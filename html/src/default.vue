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
import {connectedJoyCons} from "./components/joycon";
export default {
    name: "default.vue",
    data(){
        return {
            CBKs:[]
        }
    },
    computed: {
        currentRouteName() {
            return this.$route.name;
        }
    },
    provide() {
        return {
            connect: this.connect,
            addCBK:this.addCBK
        }
    },
    methods:{
        async connect(){
            let me = this
            let r = await JoyCon.connectJoyCon();
            me.watchStatus()
        },
        addCBK(func){
            let me = this;
            me.CBKs.push(func)
        },
        watchStatus(){
            let me = this
            setInterval(async () => {
                for (const joyCon of connectedJoyCons.values()) {
                    if (joyCon.eventListenerAttached) {
                        continue;
                    }
                    me.$notify("Joy-Con connected");
                    joyCon.eventListenerAttached = true;
                    await joyCon.disableVibration();
                    joyCon.addEventListener('hidinput', (event) => {
                        me.CBKs.forEach((func)=>{
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
