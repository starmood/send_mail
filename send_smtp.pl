#!/usr/bin/perl -w
use strict;
use utf8;
use Encode;
use MIME::Base64;
use Getopt::Long;

use Net::SMTP;
use Authen::SASL;

my $debug;
my $smtp_host;
my $smtp_user;
my $smtp_pass;
my $mail_from;
my $mail_to;
my $mail_cc;
my $mail_subject;
my $mail_body;
my $mail_headers;
my $ssl;
my $hello;
my $timeout;

my $count;
my $help;

##### Get options #####
$count=@ARGV;  # get the number of arguments

GetOptions ('h|host=s' => \$smtp_host, 
            'u|user:s' => \$smtp_user,
            'p|password:s' => \$smtp_pass,
            'f|from=s' => \$mail_from,
            't|to=s' => \$mail_to,
            'c|cc:s' => \$mail_cc,
            's|subject=s' => \$mail_subject,
            'b|body:s' => \$mail_body,
            'ssl' => \$ssl,
            'hello:s' => \$hello,
            'timeout:s' => \$timeout,
            'd|debug' => \$debug,
            'help:s' => \$help


);

if ($help or !$count) {
    &help;
    exit;
}

if (!$smtp_host or !$mail_from or !$mail_to or !$mail_subject) {
    &help;
    exit 1;
}

if (!$ssl) {
    $ssl = 0
}

if (!$hello) {
    $hello = 'localhost'
}

if (!$timeout) {
    $timeout = 120
}

if (!$debug) {
    $debug = 0
}


# for test.
#$smtp_host = 'smtp.example.com';
#$smtp_user = 'user@example.com';
#$smtp_pass = 'password';
#$mail_from = 'user@example.com';
#$mail_to = 'otheruser@example.com';
#$mail_subject = 'Test email from Net::SMTP';
#$mail_boy = mail_subject

$mail_headers = "From: $mail_from\n".
"To: $mail_to\n".
"Subject: ".encode('MIME-Header',$mail_subject)."\n".
"MIME-Version: 1.0\n".
"Content-type: text/plain; charset=UTF-8\n".
"Content-Transfer-Encoding: base64\n\n";


# send the email
my $smtp = Net::SMTP->new($smtp_host, Hello => $hello, Timeout => $timeout, Debug => $debug, SSL=> $ssl) or die "Cannot connect to $smtp_host";
if ($smtp_user) {
    $smtp->auth($smtp_user,$smtp_pass) or die "SMTP authenticate failed";
}
$smtp->mail($mail_from);
$smtp->to($mail_to);
$smtp->data();
$smtp->datasend($mail_headers);
if ($mail_body) {
    $smtp->datasend(encode_base64(encode('utf8',$mail_body)));
}
$smtp->dataend();
$smtp->quit;


sub help {
    print "Sending email through perl Net::SMTP module."
}
