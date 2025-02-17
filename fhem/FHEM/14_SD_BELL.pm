##############################################################################
# $Id$
#
# The file is part of the SIGNALduino project.
# The purpose of this module is to support many wireless BELL devices.
#
# 2018-2021 - HomeAuto_User, elektron-bbs
#
####################################################################################################################################
# - wireless doorbell TCM_234759 Tchibo  [Protocol 15] length 12-20 (3-5)
####################################################################################################################################
# - FreeTec PE-6946  [Protocol 32] length 24 (6)
#     MU;P0=146;P1=245;P3=571;P4=-708;P5=-284;P7=-6689;D=14351435143514143535353535353535353535350704040435043504350435040435353535353535353535353507040404350435043504350404353535353535353535353535070404043504350435043504043535353535353535353535350704040435043504350435040435353535353535353535353507040404350435;CP=3;R=0;O;
####################################################################################################################################
# - Elro (Smartwares) Doorbell DB200 / 16 melodies - unitec Modell:98156+98YK [Protocol 41] length 32 (8) doubleCode
#     MS;P0=-526;P1=1450;P2=467;P3=-6949;P4=-1519;D=231010101010242424242424102424101010102410241024101024241024241010;CP=2;SP=3;O;
# - KANGTAI Doorbell (Pollin 94-550405) [Protocol 41]  length 32 (8)
#     MS;P0=1399;P1=-604;P2=397;P3=-1602;P4=-7090;D=240123010101230123232301230123232301232323230123010101230123230101;CP=2;SP=4;R=248;O;m1;
####################################################################################################################################
# - Glocke Pollin 551227 [Protocol 42] length 28 (7)
#     MU;P0=-491;P1=471;P2=1445;D=0101010101010101010102020202010101010101010101010202020201010101010101010101020202020101010101010101010102020202010101;CP=1;R=67;
####################################################################################################################################
# - m-e doorbell fuer FG- und Basic-Serie  [Protocol 57] length 21-24 (6)
#     MC;LL=-653;LH=665;SL=-317;SH=348;D=D55B58;C=330;L=21;
####################################################################################################################################
# - BELL-201-TX, VTX-BELL_Funkklingel [Protocol 79] length 12 (3)  -->  Heidemann_|_Heidemann_HX_|_VTX-BELL
#     VTX-BELL, @Ralf9
#     MU;P0=656;P1=-656;P2=335;P3=-326;P4=-5024;D=01230121230123030303012423012301212301230303030124230123012123012303030301242301230121230123030303012423012301212301230303030124230123012123012303030301242301230121230123030303012423012301212301230303030124230123012123012303030301242301230121230123030303;CP=2;O;
#     BELL-201-TX, @a13xde
#     MU;P0=-7152;P1=872;P2=-593;P3=323;P4=-296;P5=622;P6=-4650;D=0123452323232323454545236345234523232323234545452363452345232323232345454523634523452323232323454545236345234523232323234545452363452345232323232345454523634523452323232323454545236345234523232323234545452363452345232323232345454523634523452323232323454;CP=3;R=26;O;
####################################################################################################################################
# - GEA-028DB  [Protocol 98] length 16 (4)
#     MU;P0=1488;P1=-585;P2=520;P3=-1509;P4=1949;P5=-5468;CP=2;R=38;D=01232301230123010101230123230101454501232301230123010101230123230101454501232301230123010101230123230101454501232301230123010101230123230101454501232301230123010101230123230101454501232301230123010101230123230101454501232301230123010101230123230101454501;O;
####################################################################################################################################
# - AVANTEK DB-LE  [Protocol 112] length 16 (4)
#     MN;D=84608A4220EF87FF;R=48;
####################################################################################################################################
# !!! ToDo´s !!!
#     - KANGTAI doubleCode must CEHCK | only one Code? - MORE USER MSG needed
#     -
####################################################################################################################################

### oberer Teil ###
package main;

use strict;
use warnings;
use lib::SD_Protocols;
use FHEM::Meta;         # https://wiki.fhem.de/wiki/Meta for SVN Revision

### HASH for all modul models ###
my %models = (
  # keys(model) => values
  'unknown' =>  { hex_lengh   => '99',      # length only for comparison
                  Protocol    => '00',
                  doubleCode  => 'no'
                },
  'TCM_234759' => { hex_lengh   => '3,4,5',
                    Protocol    => '15',
                    doubleCode  => 'no'
                  },
  'FreeTec_PE-6946' =>  { hex_lengh   => '6',
                          Protocol    => '32',
                          doubleCode  => 'no'
                        },
  'Elro_DB200_/_KANGTAI_/_unitec' =>  { hex_lengh   => '8',
                                        Protocol    => '41',
                                        doubleCode  => 'yes'
                                      },
  'Pollin_551227' =>  { hex_lengh   => '7',
                        Protocol    => '42',
                        doubleCode  => 'no'
                      },
  'FG_/_Basic-Serie' => { hex_lengh   => '6',
                          Protocol    => '57',
                          doubleCode  => 'no'
                        },
  'Heidemann_|_Heidemann_HX_|_VTX-BELL' =>  { hex_lengh   => '3',
                                              Protocol    => '79',
                                              doubleCode  => 'no'
                                            },
  'Grothe_Mistral_SE_01' => { hex_lengh   => '6', # length of device def, not message!!! message length = '10'
                              Protocol    => '96',
                              doubleCode  => 'no'
                            },
  'Grothe_Mistral_SE_03' => { hex_lengh   => '6', # length of device def, not message!!! message length = '12'
                              Protocol    => '96',
                              doubleCode  => 'no'
                            },
  'GEA-028DB' =>  { hex_lengh   => '4',
                    Protocol    => '98',
                    doubleCode  => 'no'
                  },
  'AVANTEK' =>  { hex_lengh   => '9',
                  Protocol    => '112',
                  doubleCode  => 'no'
                },
);


sub SD_BELL_Initialize {
  my ($hash) = @_;
  $hash->{Match}      = '^P(?:15|32|41|42|57|79|96|98|112)#.*';
  $hash->{DefFn}      = 'SD_BELL::Define';
  $hash->{UndefFn}    = 'SD_BELL::Undef';
  $hash->{ParseFn}    = 'SD_BELL::Parse';
  $hash->{SetFn}      = 'SD_BELL::Set';
  $hash->{AttrFn}     = 'SD_BELL::Attr';
  $hash->{AttrList}   = 'repeats:1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,20,25,30 IODev do_not_notify:1,0 ignore:0,1 showtime:1,0 model:'.join(',', sort keys %models) . " $main::readingFnAttributes";
  $hash->{AutoCreate} = {'SD_BELL.*' => {FILTER => '%NAME', autocreateThreshold => '4:180', GPLOT => ''}};

  return FHEM::Meta::InitMod( __FILE__, $hash );
}

### unterer Teil ###
package SD_BELL;

use strict;
use warnings;
use POSIX;

use GPUtils qw(:all);  # wird für den Import der FHEM Funktionen aus der fhem.pl benötigt


my $missingModul = '';

## Import der FHEM Funktionen
BEGIN {
    GP_Import(qw(
    AssignIoPort
    AttrVal
    attr
    defs
    IOWrite
    InternalVal
    Log3
    modules
    readingsBeginUpdate
    readingsBulkUpdate
    readingsDelete
    readingsEndUpdate
    readingsSingleUpdate
    ))
};


###################################
sub Define {
  my ($hash, $def) = @_;
  my @a = split("[ \t][ \t]*", $def);
  my $hash_name;
  my $name = $hash->{NAME};
  my $protocol = $a[2];
  my $doubleCode = 'no';
  my $iodevice;
  my $ioname;

  # Argument                              0     1         2         3           4
  return 'SD_BELL: wrong syntax: define <name> SD_BELL <Protocol> <HEX-Value> <optional IODEV>' if(int(@a) < 3 || int(@a) > 5);
  ### checks - doubleCode yes ###
  return "SD_BELL: wrong <protocol> $a[2]" if not($a[2] =~ /^(?:15|32|41|42|57|79|96|98|112)/xms);
  return "SD_BELL: wrong HEX-Value! Protocol $a[2] HEX-Value <$a[3]> not HEX (0-9 | a-f | A-F)" if (($protocol != 41) && not $a[3] =~ /^[0-9a-fA-F]*$/xms);
  return "SD_BELL: wrong HEX-Value! Protocol $a[2] HEX-Value <$a[3]> not HEX (0-9 | a-f | A-F) or length wrong!" if (($protocol == 41) && not $a[3] =~ /^[0-9a-fA-F]{8}_[0-9a-fA-F]{8}$/xms);

  ($hash_name) = grep { $models{$_}{Protocol} eq $protocol } keys %models;    # search protocol --> model
  $doubleCode = $models{$hash_name}{doubleCode};                              # read note doubleCode

  $hash->{doubleCode} =  'Code alternates between two RAWMSG' if($protocol == 41);
  $hash->{bitMSG} =  '';
  $hash->{lastMSG} =  '';

  $iodevice = $a[4] if($a[4]);

  $modules{SD_BELL}{defptr}{$hash->{DEF}} = $hash;
  $ioname = $modules{SD_BELL}{defptr}{ioname} if (exists $modules{SD_BELL}{defptr}{ioname} && !$iodevice);
  $iodevice = $ioname if not $iodevice;

  ### Attributes | model set after codesyntax ###
  $attr{$name}{model} = $hash_name if ( not exists($attr{$name}{model}) );    # set model, if only undef --> new def

  AssignIoPort($hash, $iodevice);

  return $@ unless ( FHEM::Meta::SetInternals($hash) );
  return;
}

###################################
sub Set {
  my ( $hash, $name, @a ) = @_;
  my $cmd = $a[0];
  my $ioname = $hash->{IODev}{NAME};
  my $model = AttrVal($name, 'model', 'unknown');
  my @split = split(' ', $hash->{DEF});
  my @splitCode = '';                             # for doubleCode
  my $protocol = $split[0];
  my $repeats = AttrVal($name,'repeats', '5');
  my $doubleCodeCheck;
  my $ret = undef;

  if ($cmd eq '?') {
    $ret .= 'ring:noArg';
    $ret .= ' Alarm:noArg' if ($protocol == 96);  # only Grothe_Mistral_SE
  } else {
    if ($protocol == 96) {; # only Grothe_Mistral_SE
      # set sduino434 raw SC;;R=5;;SR;;R=1;;P0=1500;;P1=-215;;D=01;;SM;;R=1;;C=215;;D=47104762003F;;
      my $msg = 'SC;;R=';
      $msg .= $repeats;
      $msg .= ';SR;R=1;P0=1500;P1=-215;D=01;SM;R=1;C=215;D=47';
      my $id = $split[1];
      $id = sprintf('%06X', hex(substr($id,0,6)) | 0x800000) if ($cmd eq 'Alarm');  # set alarm bit
      $msg .= $id;
      my $checksum = sprintf('%02X', ((0x47 + hex(substr($id,0,2)) + hex(substr($id,2,2)) + hex(substr($id,4,2))) & 0xFF));
      $msg .= $checksum;
      $model = AttrVal($name,'model', 'Grothe_Mistral_SE_01');
      $msg .= '3F' if ($model eq 'Grothe_Mistral_SE_03');   # only Grothe_Mistral_SE_03
      $msg .= ';';
      IOWrite($hash, 'raw', $msg);
      Log3 $name, 4, "$ioname: $name $msg";
    } else {
      my $rawDatasend = $split[1];                          # hex value from def without protocol
      if ($rawDatasend =~ /[0-9a-fA-F]_[0-9a-fA-F]/xms) {   # check doubleCode in def
      $doubleCodeCheck = 1;
      @splitCode = split('_', $rawDatasend);
      $rawDatasend = $splitCode[0];
      } else {
        $doubleCodeCheck = 0;
      }

      Log3 $name, 4, "$ioname: SD_BELL_Set_doubleCodeCheck doubleCodeCheck=$doubleCodeCheck splitCode[0]=$rawDatasend";
    
      my $msg = "P$protocol#";
      if ($protocol == 112) {
        $msg .= $rawDatasend . '0123456'; # cc1101 RX FIFO 4, 8 ... Bytes
      } else {
        my $hlen = length($rawDatasend);
        my $blen = $hlen * 4;
        my $bitData = unpack("B$blen", pack("H$hlen", $rawDatasend));
        $msg .= $bitData;
      }
    
      if ($model eq 'Heidemann_|_Heidemann_HX_|_VTX-BELL') {
        $msg .= '#R135';
      } else {
        $msg .= "#R$repeats";
      }

      Log3 $name, 4, "$ioname: $name sendMsg=$msg";
      IOWrite($hash, 'sendMsg', $msg);
    }
  }
  Log3 $name, 3, "$ioname: $name set $cmd" if ($cmd ne '?');
  readingsSingleUpdate($hash, 'state' , $cmd, 1) if ($cmd ne '?');
  return $ret;
}

###################################
sub Undef {
  my ($hash, $name) = @_;

  if(defined($hash->{DEF}) && defined($modules{SD_BELL}{defptr}{$hash->{DEF}})) {
    delete($modules{SD_BELL}{defptr}{$hash->{DEF}});
  }

  if(defined($modules{SD_BELL}{defptr}{defptr}{doubleCode})) {
    delete($modules{SD_BELL}{defptr}{doubleCode});
  }

  if(defined($modules{SD_BELL}{defptr}{defptr}{doubleCode_Time})) {
    delete($modules{SD_BELL}{defptr}{doubleCode_Time});
  }

  return;
}


###################################
sub Parse {
  my ($iohash, $msg) = @_;
  my $ioname = $iohash->{NAME};
  my ($protocol,$rawData) = split('#',$msg);
  $protocol=~ s/^[u|U|P](\d+)/$1/;                                                  # extract protocol ID, $1 = ID
  my $hlen = length($rawData);
  my $blen = $hlen * 4;
  my $bitData = unpack("B$blen", pack("H$hlen", $rawData));
  my $doubleCode_known = '0';                                                       # marker, RAWMSG known in defpr
  my ($hash_name) = grep { $models{$_}{Protocol} eq $protocol } keys %models;       # search protocol --> model
  my $deviceCode = $rawData;
  my $devicedef;
  my $state = 'ring';
  my $bat;

  Log3 $iohash, 4, "$ioname: SD_BELL_Parse protocol $protocol $hash_name doubleCode=".$models{$hash_name}{doubleCode}." rawData=$rawData";  

  ## loop to view SD_BELL defined defptr ##
  if ($protocol == 41) {
    foreach my $d(sort keys %{$modules{SD_BELL}{defptr}}) {
      Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol defptr - $d is defined!" if ($d =~ /$protocol/xms);
      if ($d =~ /$rawData/xms) {
        my @doubleCode = split(' ',$d);               # split two RAWMSG from protocol in def 41 BA7983D3_3286D393
        $doubleCode_known = $doubleCode[1];           # RAWMSG are in split RAWMSG
        Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol defptr - $rawData is already registered!"      
      }
    }

    $modules{SD_BELL}{defptr}{doubleCode_Time} = 0 if (!exists $modules{SD_BELL}{defptr}{doubleCode_Time});
    Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - doubleCode_Time_old=".$modules{SD_BELL}{defptr}{doubleCode_Time}.' Time_now='.time().' Diff='.(time()-$modules{SD_BELL}{defptr}{doubleCode_Time});

    if ((time() - $modules{SD_BELL}{defptr}{doubleCode_Time} > 15) && $doubleCode_known eq '0') {  # max timediff 15 seconds
      Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - pointer <doubleCode> not exists!" if (not exists $modules{SD_BELL}{defptr}{doubleCode});
      Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - pointer <doubleCode> ".$modules{SD_BELL}{defptr}{doubleCode}.' deleted! RAWMSG too old!' if (exists $modules{SD_BELL}{defptr}{doubleCode});
      delete ($modules{SD_BELL}{defptr}{doubleCode}) if (exists $modules{SD_BELL}{defptr}{doubleCode});
      $modules{SD_BELL}{defptr}{doubleCode_Time} = time();                                         # set time for new RAWMSG
      return '';
    }

    ### doubleCode yes and RAWMSG are unknown in def ###
    if ($models{$hash_name}{doubleCode} eq 'yes' && $doubleCode_known eq '0') {         # !defs
      Log3 $iohash, 3, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - doubleCode known $doubleCode_known in defptr. autocreate are not complete finish!";

      if (exists $modules{SD_BELL}{defptr}{doubleCode}) {
        Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - pointer <doubleCode> data already exists!";
      } else {
        $modules{SD_BELL}{defptr}{doubleCode} = $rawData.'_doubleCode';                 # first RAWMSG | reset marker, RAWMSG other
        $modules{SD_BELL}{defptr}{doubleCode_Time} = time();                            # set time from new RAWMSG
        Log3 $iohash, 3, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - ".$modules{SD_BELL}{defptr}{doubleCode}.' new defined!';
        return '';
      }

      if ($modules{SD_BELL}{defptr}{doubleCode} =~ /_doubleCode/s ) {                   # check of 2 RAWMSG
        my @doubleCode = split('_',$modules{SD_BELL}{defptr}{doubleCode});

        # Codes - common ground unknown !! #
        ####################################
        # user RAWMSG
        # 1791D593  BA2885D3
        # me RAMSG
        # 754485D3  08E8D593 ??
        # 08E8D593  754485D3 ??
        # 3286D393  BA7983D3
        # BA7983D3  3286D393

        # my $check_4 = 0;
        # $check_4 = 1 if (abs(hex(substr($doubleCode[0],4,1)) - hex(substr($rawData,4,1))) == 5);
        # my $check_5 = 0;
        # $check_5 = 1 if (substr($doubleCode[0],5,1) eq substr($rawData,5,1));
        # my $check_6 = 0;
        # $check_6 = 1 if (abs(hex(substr($doubleCode[0],6,1)) - hex(substr($rawData,6,1))) == 4);
        # my $check_7 = 0;
        # $check_7 = 1 if (substr($doubleCode[0],7,1) eq substr($rawData,7,1));

        # if ($check_4 != 1 || $check_5 != 1 || $check_6 != 1 || $check_7 != 1) {
          # Log3 $iohash, 3, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - RAWMSG check failed ($check_4 $check_5 $check_6 $check_7)";
          # return '';
        # }

        ### messages are verified ###
        if ($modules{SD_BELL}{defptr}{doubleCode} =~ /$rawData/xms) {                     # check, part known
          Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - $rawData is already known!";
        } else {                                                                        # new part
          $modules{SD_BELL}{defptr}{doubleCode} = $doubleCode[0].'_'.$rawData;
          Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - $rawData part two for defptr find!";
        }
        Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - ".$modules{SD_BELL}{defptr}{doubleCode}.' complete for defptr';
        $deviceCode = $modules{SD_BELL}{defptr}{doubleCode};
        $devicedef = $protocol . ' ' .$deviceCode;
      } else {
        if ($modules{SD_BELL}{defptr}{doubleCode} =~ /$rawData/xms) {                     # check RAWMSG known
          Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - $rawData already registered! The system search the second code.";
          $deviceCode = $modules{SD_BELL}{defptr}{doubleCode};
          $devicedef = $protocol . ' ' .$deviceCode;
        } else {
          Log3 $iohash, 3, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - RAWMSG $rawData failed! Other MSG are registered!";    # Error detections, another bit
          return '';
        }
      }
      ### doubleCode yes and RAWMSG are known in def ###
    } elsif ($models{$hash_name}{doubleCode} eq 'yes' && $doubleCode_known ne '0') {
      $devicedef = $protocol . ' ' .$doubleCode_known;                                                  # variant two, RAWMSG in a different order
      Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol doubleCode - $devicedef ready to define!";          # Error detections, another bit
    }

  ### doubleCode no - P42 must be cut manually because message has no separator ###
  } elsif ($protocol == 42) {
    ## only for RAWMSG receive from device
    if ($hlen > 7) {
      $deviceCode = substr($deviceCode,0,7);
    }
    ## if RAWMSG send from nano, not cut
    $devicedef = $protocol . ' ' .$deviceCode;
    Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol - $rawData alone";

  ### Grothe_Mistral_SE 01 or 03 length 10 or 12 nibble ###
  } elsif ($protocol == 96) {
    my $checksum = ((hex(substr($rawData,0,2)) + hex(substr($rawData,2,2)) + hex(substr($rawData,4,2)) + hex(substr($rawData,6,2))) & 0xFF);
    if ($checksum != hex(substr($rawData,8,2))) {
      Log3 $iohash, 3, "$ioname: SD_BELL_Parse Grothe_Mistral_SE $deviceCode - ERROR checksum $checksum";
      return '';
    }
    $deviceCode = sprintf('%06X', hex(substr($rawData,2,6)) & 0x7FFFFF);  # mask alarm bit
    $devicedef = $protocol . ' ' .$deviceCode;
    $state = 'Alarm' if (substr($bitData,8,1) eq '1');
    $bat = substr($bitData,41,1) eq '0' ? 'ok' : 'low' if ($hlen == 12);  # only Grothe_Mistral_SE_03
    Log3 $iohash, 4, "$ioname: SD_BELL_Parse Grothe_Mistral_SE P$protocol - $rawData";
  ### AVANTEK length 16 ###
  } elsif ($protocol == 112) {
    Log3 $iohash, 4, "$ioname: SD_BELL_Parse AVANTEK P$protocol - $rawData";
    $deviceCode = substr($deviceCode,0,9);
    $devicedef = $protocol . ' ' .$deviceCode;
  ### doubleCode no without P41 ###
  } else {
    $devicedef = $protocol . ' ' .$deviceCode;
    Log3 $iohash, 4, "$ioname: SD_BELL_Parse Check P$protocol - $rawData alone";
  }

  my $def = $modules{SD_BELL}{defptr}{$devicedef};
  $modules{SD_BELL}{defptr}{ioname} = $ioname;

  if(!$def) {
    Log3 $iohash, 1, "$ioname: SD_BELL_Parse UNDEFINED BELL detected, Protocol ".$protocol.' code ' . $deviceCode;
    return "UNDEFINED SD_BELL_$deviceCode SD_BELL $protocol $deviceCode";
  }

  my $hash = $def;
  my $name = $hash->{NAME};
  $hash->{lastMSG} = $rawData;
  $hash->{bitMSG} = $bitData;

  ### Grothe_Mistral_SE 01 or 03 length 10 or 12 nibble (only by first message) ###
  if ($protocol == 96 && $hash->{STATE} eq '???') {
    $attr{$name}{model} = 'Grothe_Mistral_SE_01' if ($hlen == 10);
    $attr{$name}{model} = 'Grothe_Mistral_SE_03' if ($hlen == 12);
  }

  my $model = AttrVal($name, 'model', 'unknown');
  Log3 $name, 4, "$ioname: SD_BELL_Parse $name model=$model state=$state ($rawData)";

  readingsBeginUpdate($hash);
  readingsBulkUpdate($hash, 'state', $state);
  readingsBulkUpdate($hash, 'batteryState', $bat) if (defined($bat) && length($bat) > 0) ;
  readingsEndUpdate($hash, 1);    # Notify is done by Dispatch

  return $name;
}

###################################
sub Attr {
  my ($cmd, $name, $attrName, $attrValue) = @_;
  my $hash = $defs{$name};
  my $typ = $hash->{TYPE};
  my $ioDev = InternalVal($name, 'LASTInputDev', undef);
  my $state;
  my $oldmodel = AttrVal($name, 'model', 'unknown');

  my @hex_lengh_def = split(' ', $defs{$name}->{DEF});
  my $hex_lengh = length($hex_lengh_def[1]);
  my $check_ok = 0;
  #Log3 $name, 3, "SD_BELL_Attr cmd=$cmd attrName=$attrName attrValue=$attrValue oldmodel=$oldmodel";

  if ($cmd eq 'set' && $attrName eq 'model' && $attrValue ne $oldmodel) {   ### set new attr
    $check_ok = 1 if ($models{$attrValue}{hex_lengh} =~ /($hex_lengh)/xms);
    return "SD_BELL: ERROR! You want to choose the $oldmodel model to $attrValue.\nPlease check your selection. Your HEX-Value in DEF with a length of " .$hex_lengh. ' are not allowed on this model!' if ($check_ok != 1 && $hex_lengh != 0);
    Log3 $name, 3, "SD_BELL_Attr $cmd $attrName to $attrValue from $oldmodel";
  }

  if ($cmd eq 'del' && $attrName eq 'model') {    ### delete readings
    readingsSingleUpdate($hash, 'state' , 'Please define a model for the correct processing',1);
  }

  return;
}

1;

=pod
=item summary    module for wireless bells
=item summary_DE Modul f&uuml;r Funk-Klingeln
=begin html

<a name="SD_BELL"></a>
<h3>SD_BELL</h3>
<ul>The module SD_BELL is a universal module of the SIGNALduino for different bells.<br><br>
  <u>Currently, the following models are supported:</u>
  <ul>
    <li>wireless doorbell TCM 234759 Tchibo  [Protocol 15]</li>
    <li>FreeTec PE-6946  [Protocol 32]</li>
    <li>Elro (Smartwares) Doorbell DB200 / 16 melodies - unitec Modell:98156+98YK [Protocol 41]</li>
    <li>Pollin 551227 [Protocol 42]</li>
    <li>m-e doorbell fuer FG- and Basic-Serie  [Protocol 57]</li>
    <li>Heidemann | Heidemann HX | VTX-BELL_Funkklingel  [Protocol 79]</li>
    <li>Grothe Mistral SE 01.1 (40 bit), 03.1 (48 bit) [Protocol 96]</li>
    <li>GEA-028DB [Protokoll 98]</li>
    <li>AVANTEK DB-LE [Protokoll 112]</li>
    <br>
    <u><i>Special feature Protocol 41, 2 different codes will be sent one after the other!</u></i>
  </ul>
  <br><br>

  <b>Define</b><br>
  <ul><code>define &lt;NAME&gt; SD_BELL &lt;protocol&gt; &lt;hex-adresse&gt;</code><br><br>
  <u>Examples:</u>
  <ul>
    define &lt;NAME&gt; SD_BELL 32 68C1DA<br>
    define &lt;NAME&gt; SD_BELL 41 754485D3_08E8D593<br>
    define &lt;NAME&gt; SD_BELL 79 A3C<br>
  </ul>
</ul><br>

  <b>Set</b><br>
  <ul>ring</ul><br>

  <b>Get</b><br>
  <ul>N/A</ul><br>

  <b>Attribute</b><br>
  <ul><li><a href="#do_not_notify">do_not_notify</a></li></ul>
  <ul><li><a href="#ignore">ignore</a></li></ul>
  <ul><li><a href="#IODev">IODev</a></li></ul>
  <ul><a name="model"></a>
    <li>model<br>
    The attribute indicates the model type of your device.<br></li></ul>
  <ul><li><a name="repeats"></a>repeats<br>
    This attribute can be used to adjust how many repetitions are sent. Default is 5.<br>
    <i>(For the model Heidemann_|_Heidemann_HX_|_VTX-BELL, the value repeats is fixed at 135!)</i></li></ul><br>
    <br>
</ul>
=end html
=begin html_DE

<a name="SD_BELL"></a>
<h3>SD_BELL</h3>
<ul>Das Modul SD_BELL ist ein Universalmodul vom SIGNALduino f&uuml;r verschiedene Klingeln.<br><br>
  <u>Derzeit werden folgende Modelle unters&uuml;tzt:</u>
  <ul>
    <li>wireless doorbell TCM 234759 Tchibo  [Protokoll 15]</li>
    <li>FreeTec PE-6946  [Protokoll 32]</li>
    <li>Elro (Smartwares) Doorbell DB200 / 16 Melodien - unitec Modell:98156+98YK [Protokoll 41]</li>
    <li>Pollin 551227 [Protokoll 42]</li>
    <li>m-e doorbell f&uuml;r FG- und Basic-Serie  [Protokoll 57]</li>
    <li>Heidemann | Heidemann HX | VTX-BELL_Funkklingel  [Protokoll 79]</li>
    <li>Grothe Mistral SE 01.1 (40 bit), 03.1 (48 bit) [Protokoll 96]</li>
    <li>GEA-028DB [Protokoll 98]</li>
    <li>AVANTEK DB-LE [Protokoll 112]</li>
    <br>
    <u><i>Besonderheit Protokoll 41, es sendet 2 verschiedene Codes nacheinader!</u></i>
  </ul>
  <br><br>

  <b>Define</b><br>
  <ul><code>define &lt;NAME&gt; SD_BELL &lt;Protokoll&gt; &lt;Hex-Adresse&gt;</code><br><br>
  <u>Beispiele:</u>
  <ul>
    define &lt;NAME&gt; SD_BELL 32 68C1DA<br>
    define &lt;NAME&gt; SD_BELL 41 754485D3_08E8D593<br>
    define &lt;NAME&gt; SD_BELL 79 A3C<br>
  </ul></ul><br>

  <b>Set</b><br>
  <ul>ring</ul><br>

  <b>Get</b><br>
  <ul>N/A</ul><br>

  <b>Attribute</b><br>
  <ul><li><a href="#do_not_notify">do_not_notify</a></li></ul>
  <ul><li><a href="#ignore">ignore</a></li></ul>
  <ul><li><a href="#IODev">IODev</a></li></ul>
  <ul><a name="model"></a>
    <li>model<br>
    Das Attribut bezeichnet den Modelltyp Ihres Ger&auml;tes.<br></li></ul>
    <ul><li><a name="repeats"></a>repeats<br>
    Mit diesem Attribut kann angepasst werden, wie viele Wiederholungen gesendet werden. Standard ist 5.<br>
    <i>(Bei dem Model Heidemann_|_Heidemann_HX_|_VTX-BELL ist der Wert repeats fest auf 135 gesetzt unabhäning vom eingestellten Attribut!)</i></li>
  </ul>
  <br><br>
</ul>
=end html_DE

=for :application/json;q=META.json 14_SD_BELL.pm
{
  "author": [
    "HomeAuto_User <>",
    "elektron-bbs"
  ],
  "description": "The module is a universal module of the SIGNALduino for different bells.",
  "dynamic_config": 1,
  "keywords": [
    "fhem-sonstige-systeme",
    "fhem-hausautomations-systeme",
    "fhem-mod",
    "signalduino"
  ],
  "license": [
    "GPL_2"
  ],
  "meta-spec": {
    "url": "https://metacpan.org/pod/CPAN::Meta::Spec",
    "version": 2
  },
  "name": "FHEM::SD_BELL",
  "prereqs": {
    "runtime": {
      "requires": {
        "FHEM": 5.00918623,
        "FHEM::Meta": 0.001006,
        "GPUtils": 0,
        "lib::SD_Protocols": "0",
        "perl": 5.018,
        "strict": "0",
        "warnings": "0"
      }
    },
    "develop": {
      "requires": {
        "lib::SD_Protocols": "0",
        "strict": "0",
        "warnings": "0"
      }
    }
  },
  "release_status": "stable",
  "resources": {
    "bugtracker": {
      "web": "https://github.com/RFD-FHEM/RFFHEM/issues"
    },
    "repository": {
      "x_master": {
        "type": "git",
        "url": "https://github.com/RFD-FHEM/RFFHEM.git",
        "web": "https://github.com/RFD-FHEM/RFFHEM/blob/master/FHEM/14_SD_BELL.pm"
      },
      "type": "svn",
      "url": "https://svn.fhem.de/fhem",
      "web": "https://svn.fhem.de/trac/browser/trunk/fhem/FHEM/14_SD_BELL.pm",
      "x_branch": "trunk",
      "x_filepath": "fhem/FHEM/",
      "x_raw": "https://svn.fhem.de/trac/export/latest/trunk/fhem/FHEM/14_SD_BELL.pm",
      "x_dev": {
        "type": "git",
        "url": "https://github.com/RFD-FHEM/RFFHEM.git",
        "web": "https://raw.githubusercontent.com/RFD-FHEM/RFFHEM/master/FHEM/14_SD_BELL.pm",
        "x_branch": "master",
        "x_filepath": "FHEM/",
        "x_raw": "https://github.com/RFD-FHEM/RFFHEM/blob/master/FHEM/14_SD_BELL.pm"
      }
    },
    "x_commandref": {
      "web": "https://commandref.fhem.de/#SD_BELL"
    },
    "x_support_community": {
      "board": "Sonstige Systeme",
      "boardId": "29",
      "cat": "FHEM - Hausautomations-Systeme",
      "title": "FHEM - Hausautomations-Systeme >> Sonstige Systeme",
      "web": "https://forum.fhem.de/index.php/board,29.0.html"
    },
    "x_wiki": {
      "web": "https://wiki.fhem.de/wiki/SD_BELL"
    }
  },
  "version": "v1.0.0",
  "x_fhem_maintainer": [
    "HomeAuto_User",
    "elektron-bbs"
  ],
  "x_fhem_maintainer_github": [
    "HomeAutoUser",
    "elektron-bbs"
  ]
}
=end :application/json;q=META.json

=cut
