//= require rails-ujs
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require bootstrap-datepicker
$(document).ready(function(){
  $('#account_birth_date').datepicker({
    format: 'dd/mm/yyyy'
  });
});
