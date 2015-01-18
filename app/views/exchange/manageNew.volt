{% extends "templates/base.volt" %}
{% block extra_js %}
    {{ javascript_include("/js/dt/jquery.dataTables.min.js") }}
    {{ javascript_include("/js/dt/dataTables.jqueryui.js") }}
    <script language="JavaScript">
        $(function() {
            $('#code-form').dataTable();
        });
    </script>
{% endblock %}
{% block extra_css %}
    {{ stylesheet_link("/css/dt/dataTables.jqueryui.css") }}
{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
        {{ form('/exchange/export', 'method':'post', 'id':'exportForm', 'name':'exportForm') }}
        <table style="margin: 0 auto; width: 100%;" border="1">
            <tr>
                <td>
                    <label for="type_id">导出兑换码类型</label>
                    <select id="type_id" name="type_id">
                        {% for type_id, type_name in type_list %}
                            <option value="{{ type_id }}">{{ type_name }}</option>
                        {% endfor %}
                    </select>
                </td>
                <td>
                    <label for="code_count">导出兑换码数量</label>
                    {{ text_field("code_count", "size":10) }}
                </td>
                <td>
                    <input type="submit" name="exportIt" id="exportIt" value="导出"/>
                </td>
            </tr>
        </table>
        {{ endform() }}
        <br />
        <br />
        <br />
        <br />
        <table  style="margin: 0 auto; width: 100%;" border="1">
            {{ form('/exchange/manageNew', 'method':'post', 'id':'codeSearch', 'name':'codeSearch') }}
            <tr>
                <td>
                    <label for="code">兑换码</label>
                    {{ text_field("code", "size": 10) }}
                </td>
                <td>
                    <label for="type">兑换码类型</label>
                    <select id="type" name="type">
                        {% for type_id, type_name in type_list %}
                            <option value="{{ type_id }}">{{ type_name }}</option>
                        {% endfor %}
                    </select>
                </td>
                <td>
                    <input type="submit" name="exportIt" id="exportIt" value="查询"/>
                </td>
            </tr>
            {{ endform() }}
        </table>
        {% if code_ret is defined %}
            <div class="ui-layout-pane" style="margin-top:100px;">
                <table id="code-form" class="display" style="text-align: center;">
                    <thead>
                    <tr>
                        <th>PK</th>
                        <th>KEY</th>
                        <th>类型</th>
                        <th>被谁使用</th>
                        <th>何时被使用</th>
                        <th>使用服务器ID</th>
                    </tr>
                    </thead>
                    <tbody>
                    {% for code in code_ret %}
                        <tr>
                            <td><label>{{ code.id }}</label></td>
                            <td><label>{{ code.code }}</label></td>
                            <td><label>{{ type_list[code.type] }}</label></td>
                            <td><label>{{ code.get_by }}</label></td>
                            <td><label>{{ code.get_at }}</label></td>
                            <td><label>{{ code.server_id }}</label></td>
                        </tr>
                    {% endfor %}
                    </tbody>
                </table>
            </div>
        {% endif %}
    {% endif %}
{% endblock %}