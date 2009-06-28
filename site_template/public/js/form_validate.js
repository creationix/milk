function form_validate(form)
{
  var good = true;
  $(".form_field", form).each(function(i,tr){
    var field = $("input,textarea,select", tr);
    console.log(field);
    var required = $(tr).hasClass('required');
    var message = "";
    var value = field[0].value;
    if (value)
    {
      if (field.hasClass("email_field"))
      {
        console.log("Validating email");
        var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!filter.test(value))
        {
          message = "Please enter a valid email address";
        }
      }
      else if (field.hasClass("phone_field"))
      {
        console.log("Validating phone");
        var stripped = value.replace(/[\s()+\-]|ext\.?/gi, "");
        // 10 is the minimum number of numbers required
        if (!(/\d{10,}/i).test(stripped))
        {
          message = "Please enter a valid phone number with area code";
        }
      }
    }
    else if (required)
    {
      message = "This is a required field";
    }
    var message_area = $(".error_message", tr);
    message_area.html(message);
    if (message === "")
    {
      message_area.hide();
    }
    else
    {
      good = false;
      message_area.show();
    }
  });
  console.log(good);
  return false;

}
