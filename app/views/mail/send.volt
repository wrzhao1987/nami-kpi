{% extends "templates/base.volt" %}
{% block extra_js %}
    <script language="JavaScript">
        $(function() {
            $("fieldset input").addClass('ui-widget-content ui-corner-all');
            $("#sub_btn").button();
            $("#add-item").button().click(function (event) {
                var curr_count = $(".attach").length + 1;
                var item_list = '<select onchange="getSubList(' + curr_count + ');" class="attach" ' +
                        'id="item_list' + curr_count + '" name="attach[' + curr_count + '][item_id]">';
                item_list = item_list + '<option value="0">请选择类型</option>';
                {% for item_id, item_name in item_list %}
                item_list = item_list + '<option value="' + {{ item_id }} + '">' + '{{ item_name }}' + '</option>'
                {% endfor %}
                item_list = item_list + '</select>';
                var attach = '<p>' + item_list
                        + '<input name="attach[' + curr_count
                        + '][count]" type="text" placeholder="请输入数量" />' + '</p>';
                $(this).before(attach);
            });
            $("#users").autocomplete({
                source: function(request, response) {
                    $.ajax({
                        url: "/ajax/username",
                        dataType: "json",
                        data: {
                            term: request.term,
                            srv_id: $("#srv_id").val()
                        },
                        success: function (data) {
                            response( $.ui.autocomplete.filter(data, extractLast(request.term)));
                        }
                    });
                },
                minLength: 1,
                delay: 300,
                focus: function () {
                    return false;
                },
                select: function( event, ui ) {
                    var terms = split( this.value );
                    // remove the current input
                    terms.pop();
                    // add the selected item
                    terms.push( ui.item.value );
                    // add placeholder to get the comma-and-space at the end
                    terms.push( "" );
                    this.value = terms.join( ", " );
                    return false;
                }
            });
        });

        function split( val ) {
            return val.split( /,\s*/ );
        }
        function extractLast( term ) {
            return split( term ).pop();
        }

        function getSubList(list_no)
        {
            var item_list = $('#item_list' + list_no);
            var sub_list  = '<select id="sub_list' + list_no +  '" name="attach[' + list_no + '][sub_id]">';
            sub_list  = sub_list + '<option value="0">请选择子类型</option>';

            $("#sub_list" + list_no).remove();
            $.getJSON('/ajax/itemsub', {item_id: item_list.val()}, function (json) {
                for (var sub_id in json) {
                    sub_list = sub_list + '<option value="' + sub_id + '">' + json[sub_id] + '</option>';
                }
                sub_list = sub_list + '</select>';
                item_list.after(sub_list);
            });
        }
        function modUserInput()
        {
            var user_field = $("input#users");
            if ($("#to-all-user").prop('checked')) {
                user_field.val("");
                user_field.prop("disabled", true);
            } else {
                user_field.prop("disabled", false);
            }
        }
    </script>
{% endblock %}
{% block extra_css %}{% endblock %}
{% block content %}
    {% if notice['code'] != 403 %}
            {{ form('/mail/send', 'method':'post', 'id':'myform', 'name':'myform') }}
            <fieldset>
                <table style="margin: 0 auto; width: 100%;" border="1">
                    <tr>
                        <td colspan="2">
                            <label>请选择服务器:</label>
                            {{ select_static("srv_id", srv_list) }}
                        </td>
                        <td colspan="2">
                            <label>请选择用户:</label>
                            {{ text_field("users", "size": 50) }}
                            <input type="checkbox" id="to-all-user" name="to-all-user" onchange="modUserInput();" />
                            <label for="to-all-user">全部用户</label>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <label>标题:</label>
                            {{ text_field("title", "size": 100) }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <label>正文:</label>
                            <br />
                            {{ text_area("content", "rows":15, "cols": 80) }}
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <a href="javascript:void(0);" id="add-item">添加一个附件</a>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" style="text-align: center;">
                            {{ submit_button("发送", "id": "sub_btn", "name": "sub_btn") }}
                        </td>
                    </tr>
                </table>
            {{ hidden_field(security.getTokenKey(), "value": security.getToken()) }}
            </fieldset>
            {{ end_form() }}
    {% endif %}
{% endblock %}