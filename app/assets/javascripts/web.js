//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker
//= require dropify/src/js/dropify

window.onload = function () {
  $('.datepicker-toggle').datepicker();

  $('#send-code-btn').on('click', function () {
    $('.loader').css("display", "block");
    $('#send-code-btn').hide();
    number = '+' + $("#country_code").val() + $("#number").val();
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

  var doc_type = $('.document_doc_type');
  toggleIdControls(doc_type.val());
  
  doc_type.on('change', function(){
    toggleIdControls(this.value);
  });

  function toggleIdControls(doc_type){
    switch (doc_type) {
      case 'DL':
        $('#doc-issued-state').show();
        $('.pp-label').hide();
        $('.id-label').hide();
        $('.dl-label').show();
        $('.file_name_2').show();
        break;
      case 'P':
        $('#doc-issued-state').hide();
        $('.pp-label').show();
        $('.id-label').hide();
        $('.dl-label').hide();
        $('.file_name_2').hide();
        break;
      default:
        $('#doc-issued-state').hide();
        $('.pp-label').hide();
        $('.id-label').show();
        $('.dl-label').hide();
        $('.file_name_2').hide();
    }
  }
};
