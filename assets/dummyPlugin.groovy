// usage: curl http://localhost:8081/artifactory/api/plugins/execute/dummyPlugin

executions {
    dummyPlugin(httpMethod: 'GET', users:['anonymous']) {
        message = '{"status":"okay"}'
        status = 200
    }
}
