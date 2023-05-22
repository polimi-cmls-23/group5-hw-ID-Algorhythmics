let noteOptions = ['C4','D4','E4','F4','G4','A4','B4','C5','D5','E5']
let leftOperationsMap ={
        upAmplitude : '↑amplitude',
        downAmplitude:'↓amplitude',
        upAttack:'↑attack time of envelope',
        downAttack:'↓attack time of envelope',
        upRelease:'↑release time of envelope',
        downRelease:'↓release time of envelope',
        upFrequency:'↑frequency of vibrato',
        downFrequency:'↓frequency of vibrato',
        upDepth:'↑depth of vibrato',
        downDepth:'↓depth of vibrato',
        upMix:'↑Mix D/W of reverb',
        downMix:'↓Mix D/W time of reverb',
        upReverbTime:'↑time of reverb',
        downReverbTime:'↓time of reverb',
        upPreDelay:'↑pre-delay of reverb',
        downPreDelay:'↓pre-daly of reverb'
}
let leftOperations = Object.values(leftOperationsMap)

let defaultHotkeys = {
        // right
        A:'C4',
        B:'D4',
        X:'E4',
        Y:'F4',
        R:'G4',
        ZR:'A4',
        RightTwist:'B4',
        RightShake:'C5',
        // left
    // 'Kick','Snare','Hi-hat'
        Up:leftOperationsMap.upAmplitude,
        Down:leftOperationsMap.downAmplitude,
        Left:leftOperationsMap.upRelease,
        Right:leftOperationsMap.downRelease,
        L:'',
        ZL:'',
        LeftTwist:'',
        LeftShake:'',
}
export {defaultHotkeys,noteOptions,leftOperations}
