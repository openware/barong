//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker
//= require dropify/src/js/dropify
//= require intl-tel-input/build/js/intlTelInput
//= require intl-tel-input/build/js/utils

window.onload = function () {
  $('.datepicker-toggle').datepicker();

  $('#phone-input').on('input', function() {
    $('#phone-input').intlTelInput(
      'setNumber',
      $('#phone-input').intlTelInput('getNumber')
    );
  });

  $('#send-code-btn').on('click', function () {
    $('#send-code-btn').hide();
    $('.loader').show();

    $('#number').val($('#phone-input').intlTelInput('getNumber'));

    $.post({
      url: 'verification',
      data: {
        number: $('#phone-input').intlTelInput('getNumber')
      },
      headers: {
        'X-CSRF-Token': $('meta[name=csrf-token]').attr('content')
      },
      success: function(result) {
          if (result.success) {
              $('.loader').hide();
              $('#error').fadeOut('fast');
              $('#send-code-btn').show();
              $('#error').text('');
              $('#create-phone').prop('disabled', false);
              $('#send-code-btn').text('Resend');
          }
      },
      error: function(result) {
          $('.loader').hide();
          $('#send-code-btn').show();
          $('#error').fadeIn('fast');
          $('#error').text(result.responseJSON.error);
      }
    });
  });

  $('.dropify').dropify({
    tpl: {
      message:  '<div class="dropify-message"><p>{{ default }}</p></div>',
    }
  });

  $('#phone-input').intlTelInput({
    separateDialCode: true,
    initialCountry: 'auto',
    geoIpLookup: function(callback) {
      $.get('https://ipinfo.io', function() {}, 'jsonp').always(function(resp) {
        callback((resp && resp.country) ? resp.country : '');
      });
    }
  });
};
