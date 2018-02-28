//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker
//= require dropify/src/js/dropify
//= require intlTelInput
//= require libphonenumber/utils

window.onload = function () {
  $('.datepicker-toggle').datepicker();

  $('#send-code-btn').on('click', function () {
    $('.loader').css("display", "block");
    $('#send-code-btn').hide();
    console.log($("#phone-input").intlTelInput("getNumber", intlTelInputUtils.numberFormat.E164))
    number = $("#phone-input").intlTelInput("getNumber");
    code = $("#phone-input").intlTelInput("getSelectedCountryData").dialCode;
    $("#code-input").val(code);

    $.ajax({
      headers: { 'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content') },
      method:  'POST',
      data:    { number: number },
      url:     'verification',
      success: function(result){
         if (result.success){
           $('.loader').css("display", "none");
           $('#send-code-btn').show();
           $("#error").text('');
           $("#create-phone").prop('disabled', false);
           $("#send-code-btn").text('Resend');
         } else {
           $('.loader').css("display", "none");
           $('#send-code-btn').show();
           $("#error").text(result.error);
         }
      }
    });
  });

  $('.dropify').dropify({
      tpl: {
          message:  '<div class="dropify-message"> <p>{{ default }}</p> </div>',
      }
  });

    $("#phone-input").intlTelInput({
        formatOnInit: true,
        separateDialCode: true,
        utilsScript: "assets/libphonenumber/utils.js"
    });
};
