#!/usr/bin/env perl

use strict;
use warnings;

use Dancer;
use PerlMetrics::Web;
use PerlMetrics::Web::GitHub;

set template => 'template_toolkit';

dance;
