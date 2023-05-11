<template>
    <div id="app">
        <img v-if="'start'!==currentRouteName" class="arrow-back" src="./assets/arrow.svg" alt="back" />
        <router-view class="view"/>
    </div>
</template>

<script>
export default {
    name: "default.vue",
    computed: {
        currentRouteName() {
            return this.$route.name;
        }
    }
}
</script>

<style scoped>
    #app{
        width: 100%;
        /*height: 100%;*/
        height: 100vh;
        /*background: black;*/
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
</style>
