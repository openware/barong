//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets


function sendVerificationCode() {
  number = $("#number").val();
   $.ajax({
     headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
     method:  'POST',
     data:    { number: number },
     url:     'verification',
     success: function(result){
        if (result.success){
          $("#error").text('');
          $("#create-phone").prop('disabled', false);
          $("#send-code-btn").prop('value', 'Resend');
        } else {
          $("#error").text('Phone number is invalid');
        };
    }});
};
