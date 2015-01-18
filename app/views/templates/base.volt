<!doctype html>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <title>{% block title %}欢迎光临{% endblock %} - Nami后台管理系统</title>
    {{ javascript_include("/js/jquery-1.10.2.js") }}
    {{ javascript_include("/js/jquery-ui-1.10.4.custom.min.js") }}
    {{ javascript_include("/js/jquery.layout-latest.js") }}
    {% block extra_js %}{% endblock %}
    {{ stylesheet_link("/css/cupertino/jquery-ui-1.10.4.custom.min.css") }}
    {{ stylesheet_link("/css/global.css") }}
    {{ javascript_include("/js/highcharts/highcharts.js") }}
    {{ javascript_include("/js/highcharts/themes/grid.js") }}
    {% block extra_css %}{% endblock %}
    <script language="javascript">
        $(function() {
            $('body').layout();
            $( "#menu-content" ).menu();
        });
    </script>
</head>
<body class="ui-layout-container">
        {{ partial("partials/login") }}
        {{ partial("partials/topbar") }}
        {{ partial("partials/menu") }}
        <div id="content" class="ui-layout-center ui-layout-pane ui-layout-pane-center">
            {% if notice['code'] > 0 %}
                <p class="ui-state-error">{{ '[' ~ notice['code'] ~ ']' ~ notice['msg'] }}</p>
            {% else %}
                {% if notice['msg'] != '' %}
                    <p class="ui-state-highlight">{{ notice['msg'] }}</p>
                {% endif %}
            {% endif %}
            {% block content%}{% endblock %}
        </div>
        {{ partial("partials/footbar") }}
</body>
</html>
