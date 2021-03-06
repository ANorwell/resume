<?php

require '../facebook-php-sdk/src/facebook.php';

// Create our Application instance (replace this with your appId and secret).
$facebook = new Facebook(array(
'appId'  => '208341082530964',
'secret' => 'ee43fb3860a6a167b0829ec299011228',
'cookie' => true,
));

// We may or may not have this data based on a $_GET or $_COOKIE based session.
//
// If we get a session here, it means we found a correctly signed session using
// the Application Secret only Facebook and the Application know. We dont know
// if it is still valid until we make an API call using the session. A session
// can become invalid if it has already expired (should not be getting the
// session back in this case) or if the user logged out of Facebook.
$session = $facebook->getSession();

$me = null;
// Session based API call.
if ($session) {
    try {
        $uid = $facebook->getUser();
        $me = $facebook->api('/me');
    } catch (FacebookApiException $e) {
        error_log($e);
    }
    
 }

// login or logout url will be needed depending on current user state.
if ($me) {
$logoutUrl = $facebook->getLogoutUrl();
} else {
$loginUrl = $facebook->getLoginUrl();
}

?>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml"
      xmlns:fb="http://www.facebook.com/2008/fbml">
  <head>

    <script type="text/javascript">
      var OLD_API = 'https://api.facebook.com/method/';
      var APP_ID = '<?php echo $facebook->getAppId(); ?>';
      var URL = 'http://anorwell.com/resume/index.php';
      var AUTH = 'https://www.facebook.com/dialog/oauth?response_type=token&client_id=' + APP_ID + '&redirect_uri='+ URL;
      var SESSION_JSON = '<?php echo json_encode($session); ?>';

      var ACCESS_TOKEN = '<?php echo $session['access_token']; ?>';
    </script>

    <title>resume tool</title>
    <link rel="stylesheet" type="text/css" href="style.css" />

    <!-- jquery + ui -->
    <link type="text/css" href="../jqueryui/css/ui-lightness/jquery-ui-1.8.4.custom.css" rel="stylesheet" />	
    <script type="text/javascript" src="../jqueryui/js/jquery-1.4.2.min.js"></script>
    <script type="text/javascript" src="../jqueryui/js/jquery-ui-1.8.4.custom.min.js"></script>


    <script type="text/javascript" src="script.js"></script>
    
    
  </head>
  <body>

    
    <!-- the facebook login button -->

    <?php if ($me): ?>
    <a href="<?php echo $logoutUrl; ?>">
      <img src="http://static.ak.fbcdn.net/rsrc.php/z2Y31/hash/cxrz4k7j.gif">
    </a>
    <?php else: ?>
    <div id="fb-root"></div>
    <script src="http://connect.facebook.net/en_US/all.js#appId=208341082530964&amp;xfbml=1"></script>
    <fb:login-button width="200" max-rows="1"></fb:login-button>
    <script type="text/javascript">
      window.fbAsyncInit = function() {
    FB.init({
        appId   : APP_ID,
                session : SESSION_JSON, // don't refetch the session when PHP already has it
                status  : true, // check login status
                cookie  : true, // enable cookies to allow the server to access the session
                xfbml   : true // parse XFBML
                });

    // whenever the user logs in, we refresh the page
    FB.Event.subscribe('auth.login', function() {
            window.location.reload();
        });
};
    </script>

    <!--
    <div>
      <a href="<?php echo $loginUrl; ?>">
        <img src="http://static.ak.fbcdn.net/rsrc.php/zB6N8/hash/4li2k73z.gif">
      </a>
    </div>
    -->
    <?php endif ?>


    <div class="main">

      <h2>Experience</h2>

      <div id="experience">
        <!--
            <div class="elt" id="proto" >
            <div class="elt-header">Position</div>
            <div class="elt-content">         
            <div>
            <label class="elt-label" for="exp-name">Name: </label>
            <input id="exp-name"></input>
            </div>

<div>
<label class="elt-label" for="exp-pos">Position: </label>
<input  id="exp-pos"></input>
</div>

<div>
<label class="elt-label" for="exp-desc">Description: </label>
<textarea id="exp-desc" cols="55" rows="5"></textarea>
</div>

</div>
</div>
!-->

        <div class="elt-set" id="exp-list"></div>


        <button class="button" id="exp-button">Add New Position</button>


      </div>
    </div>
  </body>
</html>



