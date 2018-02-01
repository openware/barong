//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker

function sendVerificationCode() {
  number = '+' + $("#country_code").val() + $("#number").val();
  $.ajax({
    headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
    method:  'POST',
    data:    { number: number },
    url:     'verification',
    success: function(result){
       if (result.success){
         $("#error").text('');
         $("#create-phone").prop('disabled', false);
         $("#send-code-btn").fadeTo( 1000, 0 );
         $("#send-code-btn").prop('disabled', true);
       } else {
         $("#error").text(result.error);
       }
    }
  });
};
