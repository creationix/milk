function on_click_sprite(e)
{
  // Look up some useful variables
  var current = e.currentTarget;
  var sprite_select = $(current.parentNode);
  var peers = $(".sprite-option", sprite_select);
  var hidden_input = $('input', sprite_select)[0];
  var inner_span = $('span', current)[0];

  // Set the value on the hidden input
  hidden_input.value = inner_span.title;

  // Move the highlight        
  peers.removeClass('ui-state-highlight');
  $(current).addClass('ui-state-highlight');
  update_preview(50);
}

function jsonify(form)
{
  var data = {}
  $("input, textarea, select", form).each(function (i, field){
    var parts = field.name.split(':');
    var root = data;
    var part = parts[0];
    var numeric_regexp = /[0-9]+/;
    for(i=0;i<parts.length-1;i++)
    {
      if (!root[part])
      {
        if (numeric_regexp.test(part))
          root[part]={};
        else
          root[part]=[];
      }
      root = root[part];
      part = parts[i + 1];
    }
    value = field.value
    if (field.type == 'checkbox')
    {
      value = field.checked;
    }
    root[part] = value;
  });
  return $.toJSON(data);
}

function do_update_preview()
{
  var preview = $("#preview");
  $("body").addClass("busy")
  $.ajax({
    type: "POST",
    url: $("form")[0].action,
    contentType: "application/json",
    data: jsonify($("form")[0]),
    success: function(msg){
      preview.html(msg);
      $("body").removeClass("busy")
    }
  });
}

function update_preview(timeout)
{
  clearTimeout(window.preview_timeout);
  window.preview_timeout = setTimeout(do_update_preview, timeout);
}


$(function() {
  $("#left").resizable({handles: "e", resize: function(event, ui) {
    $("#divider").css("left", ui.size.width);
    $("#preview").css("left", ui.size.width+5);
  }});
  $(".sub-fields").accordion({
    collapsible: true,
    autoHeight: false,
    active: false
  });
  var sections = $("#fields").accordion({
    autoHeight: false
  });
  
  $(".sprite-option").click(on_click_sprite);
 $(".toolitem, .sprite-option")
  .addClass("ui-state-default ui-corner-all")
  .hover(
    function() { $(this).addClass('ui-state-hover'); },
    function() { $(this).removeClass('ui-state-hover'); }
  );
  $("#fields select, #fields input, #fields textarea").change(function(){
    update_preview(100);
  });
  $("#fields select, #fields input, #fields textarea").keyup(function(){
    update_preview(1000);
  });
  $("#save_button").click(function(){
    $.ajax({
      type: "PUT",
      url: $("form")[0].action,
      contentType: "application/json",
      data: jsonify($("form")[0]),
      success: function(msg){
        window.location = $("form")[0].action.replace('https://', 'http://');
      }
    });
  });
  
  $("#cancel_button").click(function(){
    window.location = $("form")[0].action.replace('https://', 'http://');
  });
  $("#logout_button").click(function(){
    window.location = "/logout?dest="+$("form")[0].action.replace('https://', 'http://');
  });
  
});


