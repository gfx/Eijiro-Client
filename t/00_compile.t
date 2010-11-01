#!perl
use strict;
use Test::More;

do './eijiro.pl';
ok !$@, 'compile';

done_testing;

