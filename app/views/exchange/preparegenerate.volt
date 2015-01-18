{% extends "templates/base.volt" %}

{% block extra_js %}
    {{ javascript_include("/js/timepicker.js") }}
    <script type='text/javascript'>
        $(function() {
            $("#generate").button();
            $("fieldset input").addClass('ui-widget-content ui-corner-all');
            $("#expire").datepicker({ dateFormat: "yy-mm-dd" });
            $("#add-item").button().click(function (event) {
                var curr_count = $(".items").length;
                var item_list = '<select onchange="getSubList(' + curr_count + ');" class="items" ' +
                        'id="item_list' + curr_count + '" name="items[' + curr_count + '][item_id]">';
                item_list = item_list + '<option value="0">请选择类型</option>';
                {% for item_id, item_name in item_list %}
                item_list = item_list + '<option value="' + {{ item_id }} + '">' + '{{ item_name }}' + '</option>'
                {% endfor %}
                item_list = item_list + '</select>';
                var items = '<p>' + item_list
                        + '<input name="items[' + curr_count
                        + '][count]" type="text" placeholder="请输入数量" />' + '</p>';
                $(this).before(items);
            });
        });

        function getSubList(list_no)
        {
            var item_list = $('#item_list' + list_no);
            var sub_list  = '<select id="sub_list' + list_no +  '" name="items[' + list_no + '][sub_id]">';
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

        function submit_check() {
            var num = $("#num").val();
            num = parseInt(num);
            if ( !num || num <= 0 ) {
                alert("请指定合理数量");
                return false;
            }
            var expire = $("#expire").val();
            if ( !expire ) {
                alert("请选择过期时间");
                return false;
            }
            var items = [];
            var item_num = $(".items").length;
            if (item_num <=0) {
                alert("没有指定物品");
                return false;
            }
            for (var i=1;i<=item_num;i++) {
                var item_id = $("#item_list"+i).val();
                var sub_id = 0;
                var e_sub_id = $("select[name='items["+i+"][sub_id]']");
                if (e_sub_id.length>0) {
                    sub_id = e_sub_id[0].value;
                } else {
                    sub_id = 1;
                }
                var count = $("input[name='items["+i+"][count]']")[0].value;
                if (item_id<=0 || sub_id<=0 || count<=0) {
                    alert('物品信息不全');
                    return false;
                }
                if (item_id>0 && sub_id>0 && count>0) {
                    items.push({'item_id':item_id, 'sub_id': sub_id, 'count': count});
                }
            }
            return true;
        }
    </script>
{% endblock %}

{% block extra_css %}
    {{ stylesheet_link("/css/timepicker.css") }}
{% endblock %}

{% block content %}

<fieldset>
{% if notice['code'] != 403 %}
    {{ form('/exchange/generate', 'method':'post', 'id':'exchangeform', 'name':'exchangeform') }}
        <table style="margin: 0 auto; width: 100%;" border="1">
            <tr>
                <td>
                    <label for="title">数量</label>
                    {{ text_field("num", "size":10) }}
                </td>
                <td>
                    <label>最后有效日期</label>
                    {{ text_field("expire", "readonly": "readonly") }}
                </td>
            </tr>
            <tr>
                <td>
                    <label for="title">批次</label>
                    {{ text_field("batch", "size":10) }}
                </td>
                <td>
                    <label>请选择服务器:</label>
                    {{ select_static("srv_id", srv_list) }}
                </td>
            </tr>
            <tr>
                <td>
                    <label for="title"></label>

                </td>
            </tr>
            <tr>
                <td colspan="4">
                    <a href="javascript:void(0);" id="add-item">添加一个物品</a>
                </td>
            </tr>
        </table>
        {{ submit_button("生成", "id": "generate", "name": "generate", "onclick": "return submit_check();") }}
    {{ endform() }}
    </fieldset>
{% endif %}
{% endblock %}


