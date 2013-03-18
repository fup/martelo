$(document).ready(function() {
  $('#result').hide();
  $('#button').live('click',function(){
    var url = '/'+$('input#hostname').val()+'?app='+$('select#app').val();
    console.log(url);
    $.get(url, function(data) {
      $('#result textarea').text(data);
      $('#result').show('slow');
    });
  });
});
