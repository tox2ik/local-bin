#!/bin/bash

if [ $# -lt 3 ];
then
cat <<MOO
Albania, Leke           ALL
Afghanistan, Afghanis   AFN
Argentina, Pesos        ARS
Aruba, Guilders         AWG
Australia, Dollars      AUD
Azerbaijan, New Manats  AZN
Bahamas, Dollars        BSD
Barbados, Dollars       BBD
Belarus, Rubles         BYR
Belgium, Euro           EUR
Belize, Dollars         BZD
Bermuda, Dollars        BMD
Bolivia, Bolivianos     BOB
Bosnia and Herzegovina, BAM
Botswana, Pulas         BWP
Bulgaria, Leva          BGN
Brazil, Reais           BRL
United Kingdom Pounds   GBP
Brunei Darussalam, Dlrs BND
Cambodia, Riels         KHR
Canada, Dollars         CAD
Cayman Islands, Dollars KYD
Chile, Pesos            CLP
China, Yuan Renminbi    CNY
Colombia, Pesos         COP
Costa Rica, Colon       CRC
Croatia, Kuna           HRK
Cuba, Pesos             CUP
Cyprus, Euro            EUR
Czech Republic, Koruny  CZK
Denmark, Kroner         DKK
Dominican Rep., Pesos   DOP
East Caribbean, Dollars XCD
Egypt, Pounds           EGP
El Salvador, Colones    SVC
Euro                    EUR
Falkland Islands,Pounds FKP
Fiji, Dollars           FJD
France, Euro            EUR
Ghana, Cedis            GHC
Gibraltar, Pounds       GIP
Greece, Euro            EUR
Guatemala, Quetzales    GTQ
Guernsey, Pounds        GGP
Guyana, Dollars         GYD
Netherlands, Euro       EUR
Honduras, Lempiras      HNL
Hong Kong, Dollars      HKD
Hungary, Forint         HUF
Iceland, Kronur         ISK
India, Rupees           INR
Indonesia, Rupiahs      IDR
Iran, Rials             IRR
Ireland, Euro           EUR
Isle of Man, Pounds     IMP
Israel, New Shekels     ILS
Italy, Euro             EUR
Jamaica, Dollars        JMD
Japan, Yen              JPY
Jersey, Pounds          JEP
Kazakhstan, Tenge       KZT
Korea (North), Won      KPW
Korea (South), Won      KRW
Kyrgyzstan, Soms        KGS
Laos, Kips              LAK
Latvia, Lati            LVL
Lebanon, Pounds         LBP
Liberia, Dollars        LRD
Liechtenstein, Francs   CHF
Lithuania, Litai        LTL
Luxembourg, Euro        EUR
Macedonia, Denars       MKD
Malaysia, Ringgits      MYR
Malta, Euro             EUR
Mauritius, Rupees       MUR
Mexico, Pesos           MXN
Mongolia, Tugriks       MNT
Mozambique, Meticais    MZN
Namibia, Dollars        NAD
Nepal, Rupees           NPR
Netherlands Antilles,   ANG
Netherlands, Euro       EUR
New Zealand, Dollars    NZD
Nicaragua, Cordobas     NIO
Nigeria, Nairas         NGN
North Korea, Won        KPW
Norway, Krone           NOK
Oman, Rials             OMR
Pakistan, Rupees        PKR
Panama, Balboa          PAB
Paraguay, Guarani       PYG
Peru, Nuevos Soles      PEN
Philippines, Pesos      PHP
Poland, Zlotych         PLN
Qatar, Rials            QAR
Romania, New Lei        RON
Russia, Rubles          RUB
Saint Helena, Pounds    SHP
Saudi Arabia, Riyals    SAR
Serbia, Dinars          RSD
Seychelles, Rupees      SCR
Singapore, Dollars      SGD
Slovenia, Euro          EUR
Solomon Islands, Dlrs   SBD
Somalia, Shillings      SOS
South Africa, Rand      ZAR
South Korea, Won        KRW
Spain, Euro             EUR
Sri Lanka, Rupees       LKR
Sweden, Kronor          SEK
Switzerland, Francs     CHF
Suriname, Dollars       SRD
Syria, Pounds           SYP
Taiwan, New Dollars     TWD
Thailand, Baht          THB
Trinidad & Tobago, Dlrs TTD
Turkey, Lira            TRY
Turkey, Liras           TRL
Tuvalu, Dollars         TVD
Ukraine, Hryvnia        UAH
United Kingdom, Pounds  GBP
US of America, Dollars  USD
Uruguay, Pesos          UYU
Uzbekistan, Sums        UZS
Vatican City, Euro      EUR
Venezuela, Boliv. Fu.   VEF
Vietnam, Dong           VND
Yemen, Rials            YER
Zimbabwe, Zimbabwe Dlrs ZWD
MOO
        echo $0 FROM TO AMMOUNT
        exit 1
fi

AGENT='Mozilla/5.0 (Windows NT 6.1; WOW64; rv:5.0) Gecko/20100101 Firefox/6.0'
CURL=/usr/bin/curl

if [ `echo $1|grep -Eq '^[.0-9]{1,}$'; echo $?` -eq 0 ]
then
        AMOUNT=$1;
        FROM=$2;
        TO=$3;
else
        AMOUNT=$3;
        FROM=$1;
        TO=$2;
fi
SERVICE="https://www.xe.com/currencyconverter/convert/?Amount=${AMOUNT}&From=${FROM}&To=${TO}"


$CURL -s -A "$AGENT" "$SERVICE" |
        sed -e 's/</\n</g' |
        sed -n /ucc-container/,/uccSubTitle/p |
        html2text -nobs |
        grep = |
        sed -E -e 's/\s+/ /g; s/^ //'  |
        tac |
        tee -a ~/.xe-results


# |
# grep uccResultAndAdWrapper |
# sed '
# s/span>/span>\n/g
# s/&#10132;//
# '|
# 2>/dev/null html2text -nobs -style pretty |
# grep = | sed -e "s/^[^0-9]\+//" |
# head -n1 | sed -e 's/\ \+/ /g'

#sed -n '
#       /<tr class="uccRes"/,/<\/tr>/{
#               s/<!-- WARNING.*//
#               s/<[^>]*>//g
#               s/&nbsp;/ /
#               s/[\t\ ]*//g
#               /^$/d
#               H
#       }
#
#       ${
#               x
#               s/\n//g
#               s/=/ = /
#               s/[a-zA-Z]\{3\}/ \L&/g
#               p
#       }
#       '

