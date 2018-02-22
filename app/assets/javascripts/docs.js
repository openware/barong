//= require rails-ujs
//= require swagger-ui/dist/swagger-ui
//= require swagger-ui/dist/swagger-ui-standalone-preset

window.onload = function() {

    const ui = SwaggerUIBundle({
        url: "http://petstore.swagger.io/v2/swagger.json",
        dom_id: '#swagger-ui',
        deepLinking: true,
        presets: [
            SwaggerUIBundle.presets.apis,
            SwaggerUIStandalonePreset
        ],
        plugins: [
            SwaggerUIBundle.plugins.DownloadUrl
        ],
        layout: "StandaloneLayout"
    })
    window.ui = ui
}


