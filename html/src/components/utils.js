const key = 'config'
function isStorageExist(){
    return !!localStorage.getItem(key)
}
function readFromStorage(){
    let config = localStorage.getItem(key)
    return JSON.parse(config)
}

function save2Storage(obj){
    localStorage.setItem(key, JSON.stringify(obj));
}

export {readFromStorage,save2Storage,isStorageExist}
