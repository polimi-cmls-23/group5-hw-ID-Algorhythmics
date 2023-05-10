<template>
    <div id="app">
        <button id="back">back</button>
        <router-view class="view"/>
    </div>
</template>

<script>
export default {
    name: "default.vue"
}
</script>

<style scoped>
    #back{
        position: absolute;
        top:0;
        left: 0;
    }
    #app{
        width: 100%;
        /*height: 100%;*/
        height: 100vh;
        /*background: black;*/
        font-family: "Source Code Pro", monospace;
        background: #000;
        color:#fff;
    }
</style>
