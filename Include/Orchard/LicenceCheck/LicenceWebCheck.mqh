/*
   LicenceWebCheck.mqh
   Copyright 2021, Orchard Forex
   https://www.orchardforex.com
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link "https://www.orchardforex.com"
#property version "1.00"

// this is important for MT4
#property strict

#include "LicenceFileCheck.mqh"

class CLicenceWeb : public CLicenceFile {

protected:
   string         mAccount;
   string         mRegistration;

   virtual bool   LoadData( string &data );
   virtual string LicencePath();

public:
   CLicenceWeb( string productName, string productKey, string registration, long account = -1 );
   ~CLicenceWeb() {}

   void SetRegistration();
};

CLicenceWeb::CLicenceWeb( string productName, string productKey, string registration, long account = -1 ) : CLicenceFile( productName, productKey ) {

   mRegistration = registration;
   if ( account < 0 ) {
      account = AccountInfoInteger( ACCOUNT_LOGIN );
   }
   mAccount = string( account );
}

void   CLicenceWeb::SetRegistration() { mRegistration = Hash( mProductName + "_" + mAccount ); }

string CLicenceWeb::LicencePath() { return ( "Orchard\\Licence\\" + Hash( mProductName + "_" + mAccount ) + ".lic" ); }

bool   CLicenceWeb::LoadData( string &data ) {

   string headers = "";
   char   postData[];
   char   resultData[];
   string resultHeaders;
   int    timeout = 5000; // 1 second, may be too short for a slow connection

   string url     = "https://github.com";
   // string api     = StringFormat( "https://drive.google.com/uc?id=%s&export=download", mRegistration );
   string api     = StringFormat( "%s/OrchardForexTutorials/Licence/raw/main/%s.txt", url, mRegistration );

   ResetLastError();
   int response  = WebRequest( "GET", api, headers, timeout, postData, resultData, resultHeaders );
   int errorCode = GetLastError();

   // Add this code to handle 303 redirect but it creates more problems
   // if (response==303) {
   //	int locStart = StringFind(resultHeaders, "Location: ", 0)+10;
   //	int locEnd = StringFind(resultHeaders, "\r", locStart);
   //	api = StringSubstr(resultHeaders, locStart, locEnd-locStart);
   //	ResetLastError();
   //	response  = WebRequest( "GET", api, headers, timeout, postData, resultData, resultHeaders );
   //	errorCode = GetLastError();
   //}

   data          = CharArrayToString( resultData );

   switch ( response ) {
   case -1:
      Print( "Error in WebRequest. Error code  =", errorCode );
      Print( "Add the address " + url + " in the list of allowed URLs" );
      return false;
      break;
   case 200:
      //--- Success
      return true;
      break;
   default:
      PrintFormat( "Unexpected response code %i", response );
      return false;
      break;
   }

   return false;
}
