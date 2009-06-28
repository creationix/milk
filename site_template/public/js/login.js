$(function() {
 $("button")
  .addClass("ui-state-default ui-corner-all")
  .hover(
    function() { $(this).addClass('ui-state-hover'); },
    function() { $(this).removeClass('ui-state-hover'); }
  );
});

