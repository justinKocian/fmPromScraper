# Define custom metrics retrieval
$prod = hostname
$cpu_cores = (Get-WMIObject Win32_ComputerSystem).NumberOfLogicalProcessors
$elapsedTimeCall = (Get-Counter "\FileMaker Server 19\Elapsed Time/call").CounterSamples.CookedValue / 1000
$FileMakerClients = (Get-Counter "\FileMaker Server 19\FileMaker Clients").CounterSamples.CookedValue
$IOTimecall = (Get-Counter "\FileMaker Server 19\I/O Time/call").CounterSamples.CookedValue / 1000
$remoteCallsInProgress = (Get-Counter "\FileMaker Server 19\Remote Calls In Progress").CounterSamples.CookedValue
$waitTime = (Get-Counter "\FileMaker Server 19\wait time/call").CounterSamples.CookedValue / 1000
$cpuPercentFMServer = [Math]::Round(((Get-Counter "\process(fmserver)\% Processor Time").CounterSamples.CookedValue) / $cpu_cores)
$cpuPercentFMScriptEngine = [Math]::Round(((Get-Counter "\process(fmsase)\% Processor Time").CounterSamples.CookedValue) / $cpu_cores)
$cpuPercentFMDataAPI = [Math]::Round(((Get-Counter "\process(fmwipd)\% Processor Time").CounterSamples.CookedValue) / $cpu_cores)
$ramPercentFMServer = ([Math]::Round((Get-Counter "\process(fmserver)\working set - private").CounterSamples.CookedValue / 1MB) / [Math]::Round((Get-CimInstance Win32_PhysicalMemory | Measure-Object -Property capacity -Sum).sum / 1MB)) #.ToString("P")
        
# Prepare custom metrics in Prometheus exposition format
$prometheusMetrics = @"
# TYPE filemaker_elapsed_time_call gauge
filemaker_elapsed_time_call $($elapsedTimeCall)

# TYPE filemaker_filemaker_clients gauge
filemaker_filemaker_clients $($FileMakerClients)

# TYPE filemaker_io_time_call gauge
filemaker_io_time_call $($IOTimecall)

# TYPE filemaker_remote_calls_in_progress gauge
filemaker_remote_calls_in_progress $($remoteCallsInProgress)

# TYPE filemaker_wait_time gauge
filemaker_wait_time $($waitTime)

# TYPE filemaker_cpu_filemaker gauge
filemaker_cpu_filemaker $($cpuPercentFMServer)

# TYPE filemaker_cpu_filemaker_script_engine gauge
filemaker_cpu_filemaker_script_engine $($cpuPercentFMScriptEngine)

# TYPE filemaker_cpu_filemaker_data_api gauge
filemaker_cpu_filemaker_data_api $($cpuPercentFMDataAPI)

# TYPE filemaker_cpu_filemaker_server gauge
filemaker_cpu_filemaker_serveri $($ramPercentFMServer)
"@

# Write custom metrics to text file and convert encoding to UTF-8
$prometheusMetrics | Out-File -FilePath "C:\Program Files\windows_exporter\textfile_inputs\filemaker_metrics_$prod.prom" -Encoding UTF8
