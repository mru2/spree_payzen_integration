// Javascript to redirect to the payzen website
$(document).ready(function(){
  $('#payzen_submit').click(function(){
    $.post($('#checkout_form_payment').attr('action'),$('#checkout_form_payment').serialize());
    $('#payzen_form').submit();
  });
});