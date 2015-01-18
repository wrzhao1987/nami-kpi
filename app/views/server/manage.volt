{% extends "templates/base.volt" %}
{% block extra_css %}
<style type="text/css">
    #content {
        font-size:15px
    }
</style>
{% endblock %}

{% block extra_js %}
    {{ javascript_include("/js/timepicker.js") }}
    <script type='text/javascript'>
        $(function() {
            $(".date").each(function(){ $(this).datepicker({ dateFormat: "yy-mm-dd" }); });
            $(".time").each(function(){ $(this).timepicker(); });
        });

        function edit_server(server_id) {
            var row = document.getElementById("tr"+server_id);
            var cell0 = (row.cells[0].innerHTML);
            var cell1 = (row.cells[1].innerHTML);
            var cell2 = (row.cells[2].innerHTML);
        }

        String.prototype.trim=function() {
            return this.replace(/(^\s*)|(\s*$)/g, '');
        }

        var status_map = {
            "新区": 1,
            "爆满": 2,
            "空闲": 3,
            "维护中": 4
        };

        function submit_modify() {
            var tbl = document.getElementById("tbl_servers");
            var servers_cfg = {};
            var len = tbl.tBodies[0].rows.length;
            for (var i=0;i<len;i++) {
                var row = tbl.tBodies[0].rows[i];

                var skey = row.cells[0].innerHTML.trim();
                var sid = parseInt(row.cells[1].innerHTML.trim());
                var sname = row.cells[2].innerHTML.trim();
                var sstatus = status_map[$("#status_select_"+sid).val()];
                var op_date_start = $("#op_date_start_"+sid).val();
                var op_date_end = $("#op_date_end_"+sid).val();
                var op_time_start = $("#op_time_start_"+sid).val();
                var op_time_end = $("#op_time_end_"+sid).val();
                var op_desc = $("#op_desc_"+sid).val();
                if (sstatus == 4) {
                    if (op_date_start=="" || op_time_end=="" || op_date_end=="" || op_time_end=="") {
                        alert("维护状态需要指定维护信息");
                        return false;
                    }
                } else {
                    if (op_date_start=="" || op_time_end=="" || op_date_end=="" || op_time_end=="") {
                        //alert("非维护状态维护信息将会被忽略");
                        op_date_start = "";
                        op_time_start = "";
                        op_date_end = "";
                        op_time_end = "";
                    }
                }
                var start = (op_date_start + " " + op_time_start).trim();
                if (start.length>0) {
                    start += ":00";
                }
                var end = (op_date_end + " " + op_time_end).trim();
                if (end.length>0) {
                    end += ":00";
                }
                var cfg = {
                    'id': sid,
                    'name': sname,
                    'status': sstatus,
                    'op_time_start': start,
                    'op_time_end': end,
                    'op_desc': op_desc
                };
                servers_cfg[skey]=cfg;
            }
            $.ajax({
                dataType: "json",
                type: "post",
                url: "/server/write",
                data: $.param({'config':servers_cfg}),
                success: function(data) {
                    if (data.code==200) {
                        alert(data.msg);
                    } else if (data.msg) {
                        alert(data.msg);
                    } else {
                        alert("error");
                    }
                }
            });
        }

        function serverStatusChange(sid) {
            var sstatus = status_map[$("#status_select_"+sid).val()];
            if (sstatus != 4) {
                $("#op_date_start_"+sid).val("");
                $("#op_date_end_"+sid).val("");
                $("#op_time_start_"+sid).val("");
                $("#op_time_end_"+sid).val("");
                $("#op_desc_"+sid).val("");
            }
        }

    </script>
{% endblock %}

{% block content %}
Servers:<br/><br/>
<table id="tbl_servers" style="border-collapse: collapse;" cellpadding="5px" border="1">
    <thead>
    <tr>
        <th>id</th><th>服务器名</th><th>状态</th><th>维护开始时间</th><th>维护结束时间</th><th>维护告示</th>
    </tr>
    </thead>
    <tbody>
    {% for server_key in server_keys %}
    <tr id="tr{{servers[server_key]['id']}}">
            <td style="display:none">{{ server_key }}</td>
            <td style="width: 15px;"> {{ servers[server_key]['id'] }} </td>
            <td style="width: 150px;"> {{ servers[server_key]['name'] }} </td>
            <td style="width: 100px;" align="center">
                <select onchange="serverStatusChange({{servers[server_key]['id']}})" id="status_select_{{servers[server_key]['id']}}">
                    <option {% if servers[server_key]['status']=="1" %} selected="" {% endif %}> 新区 </option>
                    <option {% if servers[server_key]['status']=="2" %} selected="" {% endif %}> 爆满 </option>
                    <option {% if servers[server_key]['status']=="3" %} selected="" {% endif %}> 空闲 </option>
                    <option {% if servers[server_key]['status']=="4" %} selected="" {% endif %}> 维护中 </option>
                </select>
            </td>
            <td>
                {{ text_field("op_date_start_"~servers[server_key]['id'], "value":servers[server_key]['op_time_start']|parse_date, "readonly": "readonly", "class":"date", "size":8) }}
                {{ text_field("op_time_start_"~servers[server_key]['id'], "value":servers[server_key]['op_time_start']|parse_time, "readonly": "readonly", "class":"time", "size":3) }}
            </td>
            <td>
                {{ text_field("op_date_end_"~servers[server_key]['id'], "value":servers[server_key]['op_time_end']|parse_date, "readonly": "readonly", "class":"date", "size":8) }}
                {{ text_field("op_time_end_"~servers[server_key]['id'], "value":servers[server_key]['op_time_end']|parse_time, "readonly": "readonly", "class":"time", "size":3) }}
            </td>
            <td>
                {{ text_field("op_desc_"~servers[server_key]['id'], "value":servers[server_key]['op_desc']) }}
            </td>
        </tr>
    {% endfor %}
    </tbody>
</table>
<br/>
&nbsp;<button onclick="submit_modify()">保存修改</button>
<br/>


{% endblock %}


