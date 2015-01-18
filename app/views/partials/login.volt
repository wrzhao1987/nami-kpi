<script>
    $(function() {
        var name = $( "#name" ),
                password = $( "#password" ),
                allFields = $( [] ).add( name).add( password ),
                tips = $( ".validateTips" );

        function updateTips( t ) {
            tips
                    .text( t )
                    .addClass( "ui-state-highlight" );
            setTimeout(function() {
                tips.removeClass( "ui-state-highlight", 1500 );
            }, 500 );
        }

        function checkLength( o, n, min, max ) {
            if ( o.val().length > max || o.val().length < min ) {
                o.addClass( "ui-state-error" );
                updateTips(n + "的长度必须在" +
                        min + "位到" + max + "位之间." );
                return false;
            } else {
                return true;
            }
        }

        function checkRegexp( o, regexp, n ) {
            if ( !( regexp.test( o.val() ) ) ) {
                o.addClass( "ui-state-error" );
                updateTips( n );
                return false;
            } else {
                return true;
            }
        }

        $( "#login-form" ).dialog({
            autoOpen: false,
            height: 300,
            width: 350,
            modal: true,
            buttons: {
                "登录": function() {
                    var bValid = true;
                    allFields.removeClass( "ui-state-error" );

                    bValid = bValid && checkLength( name, "用户名", 3, 16 );
                    bValid = bValid && checkLength( password, "密码", 5, 16 );

                    // bValid = bValid && checkRegexp( name, /^[a-z]([0-9a-z_])+$/i, "Username may consist of a-z, 0-9, underscores, begin with a letter." );
                    // bValid = bValid && checkRegexp( password, /^([0-9a-zA-Z])+$/, "Password field only allow : a-z 0-9" );

                    if ( bValid ) {
                        $.ajax({
                            dataType: "json",
                            type: "post",
                            url: "/session/login",
                            data: "name=" + name.val() + "&password=" + password.val(),
                            success: function(data) {
                                if (data.code !== 0) {
                                    updateTips(data.msg);
                                    $( this ).dialog( "close" );
                                    return false;
                                } else {
                                    location.reload();
                                    return true;
                                }
                            }
                        });
                    }
                },
                "取消": function() {
                    $( this ).dialog( "close" );
                }
            },
            close: function() {
                allFields.val( "" ).removeClass( "ui-state-error" );
            }
        });

        $( "#login-box" )
                .button()
                .click(function() {
                    $( "#login-form" ).dialog( "open" );
                });
    });
</script>
<div id="login-form" title="请使用管理员账号登录">
    <p class="validateTips" style="border: 1px solid transparent; padding: 0.3em;"></p>
    {{ form() }}
        <fieldset>
            <label for="name">用户名:</label>
            {{ text_field("name", "class":"text ui-widget-content ui-corner-all") }}
            <label for="password">密码:</label>
            {{ password_field("password", "class":"text ui-widget-content ui-corner-all") }}
        </fieldset>
    {{ end_form() }}
</div>