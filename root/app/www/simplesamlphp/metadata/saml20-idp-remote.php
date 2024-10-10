<?php

require '/config/www/config.inc.php';

/**
 * SAML 2.0 remote IdP metadata for SimpleSAMLphp.
 *
 * Remember to remove the IdPs you don't use from this file.
 *
 * See: https://simplesamlphp.org/docs/stable/simplesamlphp-reference-idp-remote
 */
$metadata[$auth['saml']['ssp_idp']] = [
    'SingleSignOnService' => $auth['saml']['ssp_single_sign_on_service'],
    'SingleLogoutService' => $auth['saml']['ssp_single_logout_service'],
    'certData' => $auth['saml']['ssp_cert_data'],
];