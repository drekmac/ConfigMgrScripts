try{
    [datetime]$date = ((get-ciminstance -classname hwinv_localadmins -ErrorAction Stop)[0]).Date
    if($date -lt (get-date).AddDays(-1)){
        return 2
    }
    else{
        return 0
    }
}
catch{
    return 1
}

