$start = get-date -format "HH:mm:ss" 
$end = "00:30:00"
$between = New-TimeSpan -start $start -end $end
if ($start -gt $end){$between=$between.TotalSeconds+86400}
elseif  ($end -gt $start){$between=$between.TotalSeconds}
else {$between=0}
shutdown -s -t $between
