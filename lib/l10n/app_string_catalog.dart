import '../app_brand.dart';

class AppStringCatalog {
  AppStringCatalog._();

  static String translate(String source, String languageCode) {
    if (!AppBrand.isMednovations || languageCode == 'en') return source;
    if (source == 'English' ||
        source == 'हिन्दी (Hindi)' ||
        source == 'ಕನ್ನಡ (Kannada)') {
      return source;
    }
    final exact = _translations[languageCode]?[source];
    if (exact != null) return exact;
    for (final pattern
        in _patterns[languageCode] ?? const <_LocalizedPattern>[]) {
      if (pattern.translation
          .replaceAll(RegExp(r'__ARG\d+__'), '')
          .trim()
          .isEmpty) {
        continue;
      }
      final match = pattern.expression.firstMatch(source);
      if (match == null) continue;
      var result = pattern.translation;
      for (var index = 1; index <= match.groupCount; index++) {
        result = result.replaceAll(
          '__ARG${index - 1}__',
          match.group(index) ?? '',
        );
      }
      return result;
    }
    return source;
  }

  static const Map<String, Map<String, String>> _translations = {
    'hi': {
      ').replaceAll(': ').replaceAll(',
      ', member-entered': ', सदस्य द्वारा दर्ज किया गया',
      '-W': 'डब्ल्यू',
      '0 ml': '0 मिलीलीटर',
      '0% relative change': '0% सापेक्ष परिवर्तन',
      '0.0 hrs': '0.0 घंटे',
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
      '1 bowl dal': '1 कटोरी दाल',
      '1 cup cooked rice': '1 कप पका हुआ चावल',
      '1 medium banana': '1 मध्यम आकार का केला',
      '1. Retrieve your clinical records, lab test reports, immunizations, and cardiology (ECG) data from your secure on-device health database.':
          '1. अपने सुरक्षित ऑन-डिवाइस स्वास्थ्य डेटाबेस से अपने नैदानिक ​​रिकॉर्ड, प्रयोगशाला परीक्षण रिपोर्ट, टीकाकरण और कार्डियोलॉजी (ईसीजी) डेटा प्राप्त करें।',
      '1000 ml': '1000 मिलीलीटर',
      '1500 ml': '1500 मिलीलीटर',
      '2 boiled eggs': '2 उबले अंडे',
      '2. Process and cache this telemetry locally for offline visual dashboards. Your data will never be sent to any cloud backend or shared with third parties without your explicit intent.':
          '2. ऑफ़लाइन विज़ुअल डैशबोर्ड के लिए इस टेलीमेट्री डेटा को स्थानीय रूप से प्रोसेस और कैश करें। आपकी स्पष्ट अनुमति के बिना आपका डेटा कभी भी किसी क्लाउड बैकएंड पर नहीं भेजा जाएगा या तृतीय पक्षों के साथ साझा नहीं किया जाएगा।',
      '2000 ml': '2000 मिलीलीटर',
      '2026-W28': '2026-W28',
      '2500 ml': '2500 मिलीलीटर',
      '3 days left': '3 दिन शेष',
      '3. Understand that you can withdraw and revoke this consent at any time, which immediately deletes all local cache and locks medical records views.':
          '3. यह समझ लें कि आप किसी भी समय इस सहमति को वापस ले सकते हैं और रद्द कर सकते हैं, जिससे स्थानीय कैश में मौजूद सभी डेटा तुरंत डिलीट हो जाएगा और मेडिकल रिकॉर्ड देखने की सुविधा लॉक हो जाएगी।',
      '30 days': '30 दिन',
      '5-min breath reset': '5 मिनट का श्वास विश्राम',
      '500 ml': '500 मिलीलीटर',
      '6-digit code': '6-अंकीय कोड',
      '7 days': '7 दिन',
      '8+ Characters': '8+ अक्षर',
      ': (_error ??': ': (_गलती ??',
      'A balanced full-body session': 'एक संतुलित संपूर्ण शरीर सत्र',
      'A care program is ready': 'एक देखभाल कार्यक्रम तैयार है',
      'A change cannot be calculated until this measurement appears in both reports.':
          'जब तक यह माप दोनों रिपोर्टों में दिखाई नहीं देता, तब तक परिवर्तन की गणना नहीं की जा सकती।',
      'A fetchDailyHealthDataForPeriod request is already in progress. Coalescing request.':
          'fetchDailyHealthDataForPeriod अनुरोध पहले से ही प्रगति पर है। अनुरोधों को समेकित किया जा रहा है।',
      'A fetchHealthData request is already in progress. Coalescing request.':
          'एक फ़ेच हेल्थ डेटा अनुरोध पहले से ही प्रगति पर है। अनुरोधों को समेकित किया जा रहा है।',
      'A quick, private check-in — takes 10 seconds.':
          'त्वरित और गोपनीय चेक-इन — इसमें केवल 10 सेकंड लगते हैं।',
      'ACTIVE': 'सक्रिय',
      'ACTIVE GOAL HIT': 'सक्रिय लक्ष्य हासिल किया गया',
      'ACTIVE GOALS': 'सक्रिय लक्ष्य',
      'ADD OTHER CONDITION': 'अन्य शर्तें जोड़ें',
      'ADDITIONAL MEASUREMENTS': 'अतिरिक्त माप',
      'AGREE & ACTIVATE': 'सहमत हों और सक्रिय करें',
      'AI ESTIMATE': 'एआई अनुमान',
      'AI Wellness Buddy': 'एआई वेलनेस बडी',
      'AI Wellness Tips': 'एआई वेलनेस टिप्स',
      'AI features are not configured':
          'एआई सुविधाओं को कॉन्फ़िगर नहीं किया गया है',
      'AI is used to prepare a draft from the health and preference information you provide. Your company specialist reviews it before approval.':
          'आपके द्वारा दी गई स्वास्थ्य और प्राथमिकता संबंधी जानकारी से एक मसौदा तैयार करने के लिए कृत्रिम बुद्धिमत्ता (AI) का उपयोग किया जाता है। अनुमोदन से पहले आपकी कंपनी का विशेषज्ञ इसकी समीक्षा करता है।',
      'AI meal estimate': 'एआई भोजन अनुमान',
      'AI plan for your week': 'आपके सप्ताह के लिए एआई योजना',
      'AI tips': 'एआई टिप्स',
      'AM': 'पूर्वाह्न',
      'ANALYSIS LIVE': 'विश्लेषण लाइव',
      'API_BASE_URL': 'API_BASE_URL',
      'API_PATH_PREFIX': 'API_PATH_PREFIX',
      'APP_BRAND': 'ऐप_ब्रांड',
      'APP_BRAND must be medifit or mednovations':
          'APP_BRAND का नाम medifit या mednovations होना चाहिए।',
      'About the same': 'लगभग समान',
      'Absent': 'अनुपस्थित',
      'Accept program': 'कार्यक्रम स्वीकार करें',
      'Account Information': 'खाता संबंधी जानकारी',
      'Action completed.': 'कार्य पूर्ण हुआ।',
      'Action completion': 'कार्य पूर्णता',
      'Actions begin when the program is active.':
          'प्रोग्राम सक्रिय होने पर क्रियाएं शुरू होती हैं।',
      'Active': 'सक्रिय',
      'Active 2-3 times a week, moderate daily movement.':
          'सप्ताह में 2-3 बार सक्रिय रहें, प्रतिदिन मध्यम स्तर की शारीरिक गतिविधि करें।',
      'Active Calories Target 🔥': 'सक्रिय कैलोरी लक्ष्य 🔥',
      'Active Challenge': 'सक्रिय चुनौती',
      'Active Challenges': 'सक्रिय चुनौतियाँ',
      'Active workout': 'सक्रिय व्यायाम',
      'Activity': 'गतिविधि',
      'Activity Alerts': 'गतिविधि अलर्ट',
      'Activity Prompts': 'गतिविधि संकेत',
      'Activity Summary': 'गतिविधि सारांश',
      'Activity recognition permission was denied.':
          'गतिविधि पहचान की अनुमति अस्वीकृत कर दी गई।',
      'Add': 'जोड़ना',
      'Add Contact': 'संपर्क जोड़ें',
      'Add Custom Condition': 'कस्टम शर्त जोड़ें',
      'Add Emergency Contact': 'आपातकालीन संपर्क जोड़ें',
      'Add a short explanation for Other.':
          'अन्य विकल्पों के लिए संक्षिप्त स्पष्टीकरण जोड़ें।',
      'Add at least one health measurement before uploading.':
          'अपलोड करने से पहले कम से कम एक स्वास्थ्य माप अवश्य जोड़ें।',
      'Add contact': 'संपर्क जोड़ें',
      'Add custom exercise': 'कस्टम व्यायाम जोड़ें',
      'Add extra exercise': 'अतिरिक्त व्यायाम करें',
      'Add extra set': 'अतिरिक्त सेट जोड़ें',
      'Add measurement': 'माप जोड़ें',
      'Add missing workout': 'छूटे हुए व्यायाम को जोड़ें',
      'Add people who should be notified when you trigger SOS.':
          'उन लोगों को जोड़ें जिन्हें SOS ट्रिगर करने पर सूचित किया जाना चाहिए।',
      'Add to tracker': 'ट्रैकर में जोड़ें',
      'Adding…': 'जोड़ रहे हैं…',
      'Advanced': 'विकसित',
      'Aerobics': 'एरोबिक्स',
      'Aggregate Reporting to Employer': 'नियोक्ता को समग्र रिपोर्टिंग',
      'Agree & Authorize': 'सहमत हों और अधिकृत करें',
      'Alert contacts': 'संपर्कों को सूचित करें',
      'Alex Rivers': 'एलेक्स रिवर्स',
      'All alerts off': 'सभी अलर्ट बंद',
      'All displayed slots are full': 'प्रदर्शित सभी स्लॉट भरे हुए हैं',
      'All four consents below are required because a doctor must review your declared condition before clearance.':
          'नीचे दी गई चारों सहमति आवश्यक हैं क्योंकि मंजूरी देने से पहले डॉक्टर को आपकी घोषित स्थिति की समीक्षा करनी होगी।',
      'All major muscle groups': 'सभी प्रमुख मांसपेशी समूह',
      'All sets done — exercise complete':
          'सभी सेट पूरे हो गए — अभ्यास पूरा हुआ',
      'All topics': 'सभी विषय',
      'Allergies': 'एलर्जी',
      'Allergies / avoid': 'एलर्जी / परहेज करें',
      'Allow & Finish': 'अनुमति दें और समाप्त करें',
      'Allow Camera': 'कैमरा चालू करें',
      'Allow sync permissions to enable tracking.':
          'ट्रैकिंग को सक्षम करने के लिए सिंक अनुमतियां दें।',
      'Almost Synced!': 'लगभग सिंक्रनाइज़ हो गया!',
      'Already have an account?': 'क्या आपके पास पहले से एक खाता मौजूद है?',
      'Ambulance': 'एम्बुलेंस',
      'Amenities and comfort': 'सुविधाएं और आराम',
      'An unknown server error occurred.':
          'एक अज्ञात सर्वर त्रुटि उत्पन्न हुई।',
      'Analyzing lifestyle metrics and wellness goals...':
          'जीवनशैली संबंधी मापदंडों और स्वास्थ्य लक्ष्यों का विश्लेषण करना...',
      'Analyzing your activity and sleep logs... Syncing with advisor models...':
          'आपकी गतिविधि और नींद के लॉग का विश्लेषण किया जा रहा है... सलाहकार मॉडल के साथ सिंक्रनाइज़ किया जा रहा है...',
      'Ankle/foot': 'टखना/पैर',
      'Answer each question and select at least one pain area if you report pain.':
          'प्रत्येक प्रश्न का उत्तर दें और यदि आपको दर्द है तो कम से कम एक दर्द वाले क्षेत्र का चयन करें।',
      'Any cardiovascular health concerns':
          'हृदय संबंधी स्वास्थ्य संबंधी कोई भी समस्या',
      'Anything else? (optional)': 'कुछ और? (वैकल्पिक)',
      'App BMI': 'ऐप बीएमआई',
      'App resumed: fetching fresh dashboard metrics':
          'ऐप पुनः शुरू हुआ: नए डैशबोर्ड मेट्रिक्स प्राप्त किए जा रहे हैं',
      'App-calculated BMI': 'ऐप द्वारा गणना किया गया बीएमआई',
      'Appearance': 'उपस्थिति',
      'Apple': 'सेब',
      'Apple HealthKit': 'एप्पल हेल्थकिट',
      'Apple Sign In is not available here. On the simulator, open Settings and sign in with an Apple ID, enable Sign in with Apple for this App ID in Apple Developer, then do a full rebuild.':
          'यहां Apple साइन इन उपलब्ध नहीं है। सिम्युलेटर पर, सेटिंग्स खोलें और Apple ID से साइन इन करें, Apple डेवलपर में इस ऐप ID के लिए Apple के साथ साइन इन सक्षम करें, फिर पूर्ण रीबिल्ड करें।',
      'Apple Watch': 'एप्पल वॉच',
      'Apple Watch Vitals': 'एप्पल वॉच की महत्वपूर्ण जानकारी',
      'Approve': 'मंज़ूरी देना',
      'Approve & Save': 'स्वीकृत करें और सहेजें',
      'Approved': 'अनुमत',
      'Apr': 'अप्रैल',
      'Asia/Kolkata': 'एशिया/कोलकाता',
      'Ask your coach about your next workout…':
          'अपने कोच से अपने अगले वर्कआउट के बारे में पूछें…',
      'Assigned workout': 'निर्धारित व्यायाम',
      'Asthma': 'अस्थमा',
      'At a glance': 'एक नज़र में',
      'Attended': 'में भाग लिया',
      'Aug': 'अगस्त',
      'Authorization': 'प्राधिकार',
      'Average pulse': 'औसत नाड़ी',
      'BELOW TARGET': 'लक्ष्य से नीचे',
      'BLR1': 'बीएलआर1',
      'BMI': 'बीएमआई',
      'BMI context': 'बीएमआई संदर्भ',
      'BMI type': 'बीएमआई प्रकार',
      'BMR': 'बीएमआर',
      'BODY COMPOSITION': 'शरीर की संरचना',
      'Back': 'पीछे',
      'Back to Personal Info': 'व्यक्तिगत जानकारी पर वापस जाएँ',
      'Back to sign in': 'लॉग इन पर वापस जाएँ',
      'Barbell': 'लोहे का दंड',
      'Basic Profile': 'बुनियादी प्रोफ़ाइल',
      'Beginner': 'शुरुआती',
      'Begins when you accept': 'यह तब शुरू होता है जब आप स्वीकार करते हैं',
      'Better': 'बेहतर',
      'Better Sleep': 'बेहतर नींद',
      'Biceps': 'मछलियां',
      'Blood Pressure': 'रक्तचाप',
      'Blood Saturation': 'रक्त संतृप्ति',
      'Blood Sugar': 'खून में शक्कर',
      'Body Fat': 'शरीर की चर्बी',
      'Body Mass Index': 'बॉडी मास इंडेक्स',
      'Body Weight': 'शरीर का वजन',
      'Body fat': 'शरीर की चर्बी',
      'Body water': 'शरीर का पानी',
      'Bodyweight only': 'केवल शरीर का वजन',
      'Bone mass': 'अस्थि द्रव्यमान',
      'Book a Slot': 'एक स्लॉट बुक करें',
      'Book a facility activity': 'किसी सुविधा गतिविधि को बुक करें',
      'Book suggested slot': 'सुझाए गए स्लॉट को बुक करें',
      'Booked slot': 'बुक किया गया स्लॉट',
      'Booking and check-in cannot continue because the facility workflow requires workout-data access.':
          'बुकिंग और चेक-इन प्रक्रिया जारी नहीं रह सकती क्योंकि सुविधा के कार्यप्रवाह के लिए वर्कआउट डेटा तक पहुंच की आवश्यकता होती है।',
      'Bookings for today have closed at 10:00 PM. Choose tomorrow to reserve a slot.':
          'आज के लिए बुकिंग रात 10:00 बजे बंद हो गई है। कल के लिए स्लॉट आरक्षित करें।',
      'Bottle': 'बोतल',
      'Breathing time': 'सांस लेने का समय',
      'Bright, airy interface': 'चमकदार, हवादार इंटरफ़ेस',
      'Bronze Tier': 'कांस्य स्तर',
      'Build Healthy Habits': 'स्वस्थ आदतें विकसित करें',
      'Build meal plan': 'भोजन योजना बनाएं',
      'Build muscle': 'मांसपेशियों का निर्माण करें',
      'Build workout': 'व्यायाम का निर्माण करें',
      'By continuing, you agree to our':
          'जारी रखने पर, आप हमारी शर्तों से सहमत होते हैं।',
      'By enabling Medical & Health Records synchronization, you explicitly consent and authorize the application to:':
          'मेडिकल और स्वास्थ्य रिकॉर्ड सिंक्रोनाइज़ेशन को सक्षम करके, आप स्पष्ट रूप से एप्लिकेशन को निम्नलिखित कार्य करने की सहमति और अनुमति देते हैं:',
      'CARE': 'देखभाल',
      'CHALLENGES OVERVIEW': 'चुनौतियों का संक्षिप्त विवरण',
      'CM': 'सेमी',
      'COMPLETED WORKOUT': 'कसरत पूरी हुई',
      'CONTINUE': 'जारी रखना',
      'COVID-19 Vaccination': 'कोविड-19 टीकाकरण',
      'CREATE': 'बनाएं',
      'Calculated avg.': 'गणना किया गया औसत।',
      'Call': 'पुकारना',
      'Calories': 'कैलोरी',
      'Calories & Exercise time': 'कैलोरी और व्यायाम का समय',
      'Calories Burned': 'कैलोरी जला दिया',
      'Calories today': 'आज की कैलोरी',
      'Calves': 'बछड़ों',
      'Camera access is needed': 'कैमरा एक्सेस आवश्यक है',
      'Camera access is required to scan a body-composition report.':
          'शरीर की संरचना संबंधी रिपोर्ट को स्कैन करने के लिए कैमरे की पहुंच आवश्यक है।',
      'Camera access is required to scan the facility QR.':
          'सुविधा के क्यूआर कोड को स्कैन करने के लिए कैमरा एक्सेस आवश्यक है।',
      'Camera access is required to scan the facility QR. Enable it in Settings.':
          'सुविधा के क्यूआर कोड को स्कैन करने के लिए कैमरा एक्सेस आवश्यक है। इसे सेटिंग्स में सक्षम करें।',
      'Camera permission required': 'कैमरा अनुमति आवश्यक है',
      'Camera scan': 'कैमरा स्कैन',
      'Camera unavailable': 'कैमरा उपलब्ध नहीं है',
      'Cancel': 'रद्द करना',
      'Can’t scan the sticker? Enter the facility code.':
          'क्या आप स्टिकर को स्कैन नहीं कर पा रहे हैं? सुविधा कोड दर्ज करें।',
      'Capture BMI report': 'बीएमआई रिपोर्ट कैप्चर करें',
      'Carbs': 'कार्बोहाइड्रेट',
      'Cardiology': 'कार्डियलजी',
      'Care Programs': 'देखभाल कार्यक्रम',
      'Care Programs could not be loaded.': 'देखभाल कार्यक्रम लोड नहीं हो सके।',
      'Care Programs request failed': 'देखभाल कार्यक्रम अनुरोध विफल रहा',
      'Care Team': 'देखभाल टीम',
      'Care actions completed': 'देखभाल संबंधी कार्य पूर्ण हो गए',
      'Care program': 'देखभाल कार्यक्रम',
      'Care program completed': 'देखभाल कार्यक्रम पूरा हुआ',
      'Care program paused': 'देखभाल कार्यक्रम स्थगित',
      'Care progress is unavailable':
          'देखभाल की प्रगति की जानकारी उपलब्ध नहीं है।',
      'Care team professional': 'देखभाल टीम पेशेवर',
      'Challenge & Updates': 'चुनौतियाँ और अपडेट',
      'Challenge Updates': 'चुनौती अपडेट',
      'Challenge ended — calculating verified results during the sync grace period.':
          'चुनौती समाप्त हुई — सिंक्रोनाइज़ेशन के लिए निर्धारित समय सीमा के दौरान सत्यापित परिणामों की गणना की जा रही है।',
      'Challenge ended — results are calculating.':
          'चुनौती समाप्त हुई — परिणामों की गणना की जा रही है।',
      'Challenges': 'चुनौतियां',
      'Challenges 🏆': 'चुनौतियाँ 🏆',
      'Change from earlier': 'पहले से बदलाव',
      'Change session type': 'सत्र का प्रकार बदलें',
      'Change type': 'परिवर्तन प्रकार',
      'Chat deleted.': 'चैट डिलीट कर दी गई।',
      'Chat history': 'चैट का इतिहास',
      'Check in': 'चेक इन',
      'Check in now': 'अभी चेक इन करें',
      'Check in now. Your facility manager will be notified.':
          'अभी चेक इन करें। आपके सुविधा प्रबंधक को सूचित कर दिया जाएगा।',
      'Check in now; your facility manager is notified':
          'अभी चेक इन करें; आपके सुविधा प्रबंधक को सूचित कर दिया गया है।',
      'Check out': 'चेक आउट',
      'Check out now, or keep working. Keeping the session open will notify the facility manager.':
          'अभी चेकआउट करें या काम जारी रखें। सेशन खुला रखने से सुविधा प्रबंधक को सूचना मिल जाएगी।',
      'Check status': 'स्थिति जाँचिए',
      'Check that every number is readable.':
          'यह सुनिश्चित करें कि प्रत्येक संख्या पठनीय हो।',
      'Check your connection and try again.':
          'अपना इंटरनेट कनेक्शन जांचें और दोबारा प्रयास करें।',
      'Check-in logged': 'चेक-इन दर्ज हो गया',
      'Checklist completion': 'चेकलिस्ट पूर्ण करना',
      'Checkout': 'चेक आउट',
      'Chest': 'छाती',
      'Choose Gym, Yoga, Zumba, or another hourly activity, then reserve a slot or check in when you arrive.':
          'जिम, योगा, ज़ुम्बा या कोई अन्य घंटेवार गतिविधि चुनें, फिर एक स्लॉट आरक्षित करें या पहुंचने पर चेक इन करें।',
      'Choose a WhatsApp or gallery screenshot.':
          'व्हाट्सएप या गैलरी का स्क्रीनशॉट चुनें।',
      'Choose any two distinct saved reports. Reports from the same date are allowed.':
          'कोई भी दो अलग-अलग सेव की गई रिपोर्ट चुनें। एक ही तारीख की रिपोर्ट भी स्वीकार्य हैं।',
      'Choose how you want to add a body-composition report.':
          'आप बॉडी-कंपोजिशन रिपोर्ट को किस प्रकार जोड़ना चाहते हैं, यह चुनें।',
      'Choose language': 'भाषा चुनें',
      'Choose your organization': 'अपना संगठन चुनें',
      'City Health Clinic': 'सिटी हेल्थ क्लिनिक',
      'City Hospital': 'सिटी हॉस्पिटल',
      'Cleanliness': 'स्वच्छता',
      'Clear filters': 'फ़िल्टर साफ़ करें',
      'Clear search': 'खोज साफ़ करें',
      'Clinical Details & Telemetry:': 'नैदानिक ​​विवरण और टेलीमेट्री:',
      'Close': 'बंद करना',
      'Collapse': 'गिर जाना',
      'Combined': 'संयुक्त',
      'Combined activity': 'संयुक्त गतिविधि',
      'Comment': 'टिप्पणी',
      'Company': 'कंपनी',
      'Compare Reports': 'रिपोर्टों की तुलना करें',
      'Compare any two saved body-composition reports.':
          'शरीर की संरचना से संबंधित किन्हीं दो सहेजी गई रिपोर्टों की तुलना करें।',
      'Comparison actions': 'तुलनात्मक क्रियाएँ',
      'Comparison deleted.': 'तुलना हटा दी गई।',
      'Comparison period': 'तुलना अवधि',
      'Comparison status': 'तुलना स्थिति',
      'Comparison updated.': 'तुलना को अद्यतन किया गया।',
      'Comparison values come from these two saved health reports. Choose the report whose measurements you want to correct.':
          'तुलना के मान इन दो सहेजी गई स्वास्थ्य रिपोर्टों से लिए गए हैं। उस रिपोर्ट का चयन करें जिसके मापों को आप सही करना चाहते हैं।',
      'Comparisons': 'तुलना',
      'Compete': 'पूरा',
      'Compete with users in fun activities.':
          'अन्य उपयोगकर्ताओं के साथ मनोरंजक गतिविधियों में प्रतिस्पर्धा करें।',
      'Complete': 'पूरा',
      'Complete a Gym Access workout to see your checklist, session facts, and estimated workout insights here.':
          'जिम एक्सेस वर्कआउट पूरा करने के बाद, आप यहां अपनी चेकलिस्ट, सेशन की जानकारी और अनुमानित वर्कआउट की जानकारी देख सकते हैं।',
      'Completed': 'पुरा होना।',
      'Completion': 'समापन',
      'Configure daily health targets below. Your custom goals directly update the Wellness Meter calculations and recommendations.':
          'नीचे दैनिक स्वास्थ्य लक्ष्य निर्धारित करें। आपके द्वारा निर्धारित लक्ष्य सीधे वेलनेस मीटर की गणनाओं और अनुशंसाओं को अपडेट करते हैं।',
      'Configure which alerts you would like to receive. These settings are synchronized across your devices.':
          'आप जिन अलर्ट को प्राप्त करना चाहते हैं, उन्हें कॉन्फ़िगर करें। ये सेटिंग्स आपके सभी डिवाइसों पर सिंक्रोनाइज़ हो जाएंगी।',
      'Confirm AI processing consent':
          'एआई प्रोसेसिंग के लिए सहमति की पुष्टि करें',
      'Confirm consent': 'सहमति की पुष्टि करें',
      'Confirmed value': 'पुष्ट मूल्य',
      'Connect': 'जोड़ना',
      'Connect Health Connect': 'कनेक्ट हेल्थ कनेक्ट',
      'Connect Health Services': 'कनेक्ट हेल्थ सर्विसेज',
      'Connected': 'जुड़े हुए',
      'Connected Successfully': 'सफलतापूर्वक कनेक्ट हो गया',
      'Connected to Health Services': 'स्वास्थ्य सेवाओं से जुड़ा हुआ',
      'Connection Progress': 'कनेक्शन प्रगति',
      'Connection refused': 'कनेक्शन नहीं हो सका',
      'Consent & Authorization': 'सहमति और प्राधिकरण',
      'Consent Active - Tap to Revoke':
          'सहमति सक्रिय है - रद्द करने के लिए टैप करें',
      'Consent Form: Medical Records Sync':
          'सहमति प्रपत्र: चिकित्सा रिकॉर्ड का सिंक्रनाइज़ेशन',
      'Consistency': 'स्थिरता',
      'Contact added': 'संपर्क जोड़ा गया',
      'Contact deleted': 'संपर्क हटा दिया गया',
      'Contact updated': 'संपर्क अपडेट किया गया',
      'Contacts, services & one-tap alert':
          'संपर्क, सेवाएं और एक टैप में अलर्ट',
      'Content-Type': 'सामग्री-प्रकार',
      'Continue': 'जारी रखना',
      'Continue with Apple': 'Apple के साथ जारी रखें',
      'Continue with Google': 'Google के साथ जारी रखें',
      'Copy JSON': 'JSON कॉपी करें',
      'Core': 'मुख्य',
      'Correct body & recovery data': 'शरीर और रिकवरी संबंधी सही डेटा',
      'Correct missed or extra work from this session. Assigned exercises cannot be removed. Extra work is listed separately and does not raise plan completion.':
          'इस सत्र में छूटे हुए या अतिरिक्त कार्य को पूरा करें। दिए गए अभ्यासों को हटाया नहीं जा सकता। अतिरिक्त कार्य अलग से सूचीबद्ध हैं और योजना पूर्णता को प्रभावित नहीं करते हैं।',
      'Could not book this slot.': 'यह स्लॉट बुक नहीं हो सका।',
      'Could not complete checkout.': 'चेकआउट प्रक्रिया पूरी नहीं हो सकी।',
      'Could not complete the workout session. Please try again.':
          'वर्कआउट सेशन पूरा नहीं हो सका। कृपया पुनः प्रयास करें।',
      'Could not create the PDF report. Please try again.':
          'पीडीएफ रिपोर्ट नहीं बन सकी। कृपया पुनः प्रयास करें।',
      'Could not fetch ID token': 'आईडी टोकन प्राप्त नहीं हो सका',
      'Could not load SOS data': 'SOS डेटा लोड नहीं हो सका',
      'Could not load facilities.': 'सुविधाएं लोड नहीं हो सकीं।',
      'Could not load graph': 'ग्राफ लोड नहीं हो सका',
      'Could not load organizations': 'संगठनों को लोड नहीं किया जा सका',
      'Could not load organizations.': 'संगठनों को लोड नहीं किया जा सका।',
      'Could not load the exercise library.':
          'अभ्यास लाइब्रेरी लोड नहीं हो सकी।',
      'Could not load water logs': 'जल लॉग लोड नहीं हो सके',
      'Could not load workout reports': 'वर्कआउट रिपोर्ट लोड नहीं हो सकीं',
      'Could not load your chat history. Please try again.':
          'आपकी चैट हिस्ट्री लोड नहीं हो सकी। कृपया पुनः प्रयास करें।',
      'Could not load your check-in history.':
          'आपकी चेक-इन हिस्ट्री लोड नहीं हो सकी।',
      'Could not load your comparisons': 'आपकी तुलनाएँ लोड नहीं हो सकीं',
      'Could not load your health reports':
          'आपकी स्वास्थ्य रिपोर्ट लोड नहीं हो सकीं',
      'Could not play this exercise video.': 'यह व्यायाम वीडियो नहीं चल सका।',
      'Could not refresh the exercise library.':
          'अभ्यास पुस्तकालय को रीफ़्रेश नहीं किया जा सका।',
      'Could not save the workout correction.':
          'वर्कआउट करेक्शन को सेव नहीं किया जा सका।',
      'Could not save your language. Please try again.':
          'आपकी भाषा सहेजी नहीं जा सकी। कृपया पुनः प्रयास करें।',
      'Could not start the demonstration video.':
          'डेमो वीडियो शुरू नहीं हो सका।',
      'Could not start the workout.': 'वर्कआउट शुरू नहीं हो सका।',
      'Could not submit workout feedback. Try again.':
          'वर्कआउट फीडबैक सबमिट नहीं हो सका। कृपया पुनः प्रयास करें।',
      'Could not take the photo.': 'फोटो नहीं खींच सका।',
      'Could not update the facility privacy setting.':
          'सुविधा की गोपनीयता सेटिंग को अपडेट नहीं किया जा सका।',
      'Create Account': 'खाता बनाएं',
      'Create your account': 'अपना खाता बनाएं',
      'Critical': 'गंभीर',
      'Cup': 'कप',
      'Custom': 'रिवाज़',
      'Custom Amount': 'अनुकूलित राशि',
      'Custom condition': 'कस्टम स्थिति',
      'Custom exercise': 'अनुकूलित व्यायाम',
      'DAILY DIGEST': 'दैनिक खुलासा',
      'DAILY WELLNESS': 'दैनिक स्वास्थ्य',
      'DEBUG_LAN_API_BASE_URL': 'DEBUG_LAN_API_BASE_URL',
      'DELETE': 'मिटाना',
      'DETAILED RECORD HISTORY': 'विस्तृत अभिलेख इतिहास',
      'DOB': 'जन्म तिथि',
      'Daily': 'दैनिक',
      'Daily Alerts': 'दैनिक अलर्ट',
      'Daily Step Goal 👣': 'दैनिक कदमों का लक्ष्य 👣',
      'Daily Steps': 'दैनिक कदम',
      'Daily Steps & Distance': 'दैनिक कदम और दूरी',
      'Daily Wellness Reminder': 'दैनिक स्वास्थ्य अनुस्मारक',
      'Daily Wellness Summary': 'दैनिक स्वास्थ्य सारांश',
      'Dark': 'अँधेरा',
      'Date not recorded': 'तिथि दर्ज नहीं की गई',
      'Date of Birth': 'जन्म तिथि',
      'Date of birth': 'जन्म तिथि',
      'Date:': 'तारीख:',
      'Day': 'दिन',
      'Day-by-Day Logs (Last 7 Days)': 'दिन-प्रतिदिन का विवरण (पिछले 7 दिन)',
      'Dec': 'दिसम्बर',
      'Decline': 'गिरावट',
      'Delete': 'मिटाना',
      'Delete chat': 'चैट हटाएं',
      'Delete chat?': 'चैट डिलीट करें?',
      'Delete comparison': 'तुलना हटाएं',
      'Delete comparison?': 'तुलना हटाएं?',
      'Delete contact?': 'संपर्क हटाएं?',
      'Delete health report?': 'स्वास्थ्य रिपोर्ट हटाएं?',
      'Delete report': 'रिपोर्ट हटाएं',
      'Describe your meal': 'अपने भोजन का वर्णन करें',
      'Desk job, little to no exercise in a typical week.':
          'डेस्क जॉब, सामान्य सप्ताह में नाममात्र का या बिल्कुल भी व्यायाम नहीं।',
      'Detail': 'विवरण',
      'Detailed front and back anatomy map. All listed targets are highlighted in red.':
          'सामने और पीछे की संरचना का विस्तृत मानचित्र। सूचीबद्ध सभी लक्ष्य लाल रंग में हाइलाइट किए गए हैं।',
      'Device sync error': 'डिवाइस सिंक त्रुटि',
      'Diabetes': 'मधुमेह',
      'Dietary preference': 'आहार संबंधी प्राथमिकता',
      'Dietitian · Nutrition guidance':
          'आहार विशेषज्ञ · पोषण संबंधी मार्गदर्शन',
      'Directions could not be opened.': 'निर्देश नहीं खोले जा सके।',
      'Disabled': 'अक्षम',
      'Disconnect': 'डिस्कनेक्ट',
      'Disconnected': 'डिस्कनेक्ट किया गया',
      'Displaying static mockup info.':
          'स्थैतिक मॉकअप की जानकारी प्रदर्शित की जा रही है।',
      'Do you feel any pain?': 'क्या आपको कोई दर्द महसूस हो रहा है?',
      'Do you feel any progress?': 'क्या आपको कोई प्रगति महसूस हो रही है?',
      'Don\'t have an account?': 'क्या आपके पास खाता नहीं है?',
      'Done': 'हो गया',
      'Done Editing': 'संपादन हो गया',
      'Dose: 0.5 mL, Route: Intramuscular (IM) Left Deltoid. Manufacturer: Sanofi Pasteur. Lot: TD8932A. Next booster recommended in 10 years.':
          'खुराक: 0.5 मिलीलीटर, इंजेक्शन का तरीका: इंट्रामस्कुलर (आईएम) बाएँ डेल्टॉइड मांसपेशी में। निर्माता: सैनोफी पाश्चर। बैच: TD8932A। अगला बूस्टर 10 साल बाद अनुशंसित है।',
      'Down': 'नीचे',
      'Download': 'डाउनलोड करना',
      'Download Health Connect': 'हेल्थ कनेक्ट डाउनलोड करें',
      'Download PDF': 'पीडीएफ डाउनलोड करें',
      'Download completion summary': 'डाउनलोड पूर्णता सारांश',
      'Download progress PDF': 'प्रगति पीडीएफ डाउनलोड करें',
      'Dumbbells': 'डम्बल',
      'Duplicate or incorrect session': 'डुप्लिकेट या गलत सत्र',
      'Duration': 'अवधि',
      'Duration in minutes (optional)': 'अवधि (मिनटों में) (वैकल्पिक)',
      'ECG Rhythm Check': 'ईसीजी रिदम चेक',
      'ECG Rhythm Recording': 'ईसीजी रिदम रिकॉर्डिंग',
      'EDITED BY MEMBER': 'सदस्य द्वारा संपादित',
      'EMAIL ADDRESS': 'मेल पता',
      'EMERGENCY CONTACTS': 'आपातकालीन संपर्क',
      'EMERGENCY SERVICES': 'आपातकालीन सेवाएं',
      'EST. CALORIES BURNED': 'अनुमानित कैलोरी खपत',
      'Each additional measurement needs a label and number.':
          'प्रत्येक अतिरिक्त माप के लिए एक लेबल और संख्या की आवश्यकता होती है।',
      'Each card shows the earlier value, latest value, and exact change.':
          'प्रत्येक कार्ड पर पहले का मूल्य, नवीनतम मूल्य और सटीक वापसी राशि दिखाई गई है।',
      'Earlier': 'पहले',
      'Earlier conversation': 'पिछली बातचीत',
      'Earlier report': 'पिछली रिपोर्ट',
      'Earn achievements and premium badges.':
          'उपलब्धियां और प्रीमियम बैज अर्जित करें।',
      'Easy on the eyes at night': 'रात में आंखों को आराम देता है',
      'Edit': 'संपादन करना',
      'Edit Contact': 'संपादित संपर्क',
      'Edit Profile': 'प्रोफ़ाइल संपादित करें',
      'Edit Water Log': 'जल लॉग संपादित करें',
      'Edit a completed session': 'पूर्ण सत्र को संपादित करें',
      'Edit comparison': 'तुलना संपादित करें',
      'Edit comparison reports': 'तुलना रिपोर्ट संपादित करें',
      'Edit details': 'विवरण संपादित करें',
      'Edit health report': 'स्वास्थ्य रिपोर्ट संपादित करें',
      'Edit member-entered workout':
          'सदस्य द्वारा दर्ज किए गए व्यायाम कार्यक्रम को संपादित करें',
      'Edit profile': 'प्रोफ़ाइल संपादित करें',
      'Edit report': 'रिपोर्ट संपादित करें',
      'Edit weekly workouts': 'साप्ताहिक वर्कआउट संपादित करें',
      'Edit workout': 'कसरत संपादित करें',
      'Email': 'ईमेल',
      'Emergency': 'आपातकाल',
      'Empty server response': 'सर्वर की प्रतिक्रिया खाली है',
      'Enable Health Connect Sync option':
          'हेल्थ कनेक्ट सिंक विकल्प को सक्षम करें',
      'Enabled': 'सक्रिय',
      'Encrypting medical health profile...':
          'मेडिकल हेल्थ प्रोफाइल को एन्क्रिप्ट करना...',
      'Ended': 'समाप्त',
      'Ends': 'समाप्त होता है',
      'Ends today': 'आज समाप्त हो रहा है',
      'Endurance': 'धैर्य',
      'English': 'अंग्रेज़ी',
      'Enter a new password for your account (minimum 6 characters).':
          'अपने खाते के लिए एक नया पासवर्ड दर्ज करें (कम से कम 6 अक्षर)।',
      'Enter a work email': 'अपना कार्यस्थल ईमेल पता दर्ज करें',
      'Enter amount (ml)': 'मात्रा दर्ज करें (मिलीलीटर)',
      'Enter condition name': 'शर्त का नाम दर्ज करें',
      'Enter the 6-digit code we emailed you. It expires in 15 minutes.':
          'हमने आपको ईमेल द्वारा भेजा गया 6 अंकों का कोड दर्ज करें। यह 15 मिनट में समाप्त हो जाएगा।',
      'Enter the Code': 'कोड दर्ज करें',
      'Enter the facility code first.': 'सबसे पहले सुविधा कोड दर्ज करें।',
      'Enter the verification code.': 'सत्यापन कोड दर्ज करें।',
      'Enter value': 'मान दर्ज करें',
      'Enter volume (ml)': 'मात्रा (मिलीलीटर) दर्ज करें',
      'Enter your registered email address to receive a 6-digit OTP code.':
          '6 अंकों का ओटीपी कोड प्राप्त करने के लिए अपना पंजीकृत ईमेल पता दर्ज करें।',
      'Equipment (pick any)': 'उपकरण (कोई भी चुनें)',
      'Equipment and resources': 'उपकरण और संसाधन',
      'Est. energy burn': 'अनुमानित ऊर्जा खपत',
      'Establishing secure local environment...':
          'सुरक्षित स्थानीय वातावरण स्थापित करना...',
      'Estimate nutrition': 'पोषण का अनुमान लगाएं',
      'Estimated calories': 'अनुमानित कैलोरी',
      'Estimated calories, intensity, summary, and recovery guidance are AI-generated estimates from this session\'s duration and workout plan. They are not medical advice.':
          'अनुमानित कैलोरी, तीव्रता, सारांश और रिकवरी संबंधी मार्गदर्शन इस सत्र की अवधि और वर्कआउट प्लान के आधार पर AI द्वारा उत्पन्न अनुमान हैं। इन्हें चिकित्सीय सलाह नहीं माना जाना चाहिए।',
      'Estimated calories, intensity, summary, and recovery guidance are generated from this session\'s duration and workout plan. They are not medical advice.':
          'इस सेशन की अवधि और वर्कआउट प्लान के आधार पर अनुमानित कैलोरी, तीव्रता, सारांश और रिकवरी संबंधी मार्गदर्शन तैयार किए गए हैं। इन्हें चिकित्सीय सलाह नहीं माना जाना चाहिए।',
      'Estimating your meal…': 'अपने भोजन का अनुमान लगाना…',
      'Excellent': 'उत्कृष्ट',
      'Exception:': 'अपवाद:',
      'Exercise': 'व्यायाम',
      'Exercise Duration Target ⏱️': 'व्यायाम की अवधि का लक्ष्य ⏱️',
      'Exercise Library': 'अभ्यास पुस्तकालय',
      'Exercise name': 'अभ्यास का नाम',
      'Exercise video': 'व्यायाम वीडियो',
      'Exercise videos': 'व्यायाम वीडियो',
      'Exercise videos are not available yet.':
          'व्यायाम के वीडियो अभी उपलब्ध नहीं हैं।',
      'Experience': 'अनुभव',
      'Explicit consent required to access clinical reports.':
          'नैदानिक ​​रिपोर्टों तक पहुँचने के लिए स्पष्ट सहमति आवश्यक है।',
      'Explore New Challenges': 'नई चुनौतियों का सामना करें',
      'Extra exercises': 'अतिरिक्त व्यायाम',
      'Extra sets': 'अतिरिक्त सेट',
      'Extra work': 'अतिरिक्त काम',
      'F': 'एफ',
      'FULL NAME': 'पूरा नाम',
      'Facilities are ordered by your preference, recommendations, and visits.':
          'सुविधाओं को आपकी पसंद, अनुशंसाओं और आपके द्वारा किए गए दौरों के आधार पर क्रमबद्ध किया गया है।',
      'Facility': 'सुविधा',
      'Facility code': 'सुविधा कोड',
      'Facility workout': 'सुविधा व्यायाम',
      'Facility workout-data sharing': 'सुविधा संबंधी व्यायाम-डेटा साझाकरण',
      'Facility workout-data sharing withdrawn. Manager access ends now, and new bookings and check-ins are blocked until you approve again.':
          'सुविधा केंद्र में वर्कआउट डेटा साझा करने की सुविधा बंद कर दी गई है। मैनेजर की पहुंच अब समाप्त हो गई है, और आपकी पुनः स्वीकृति मिलने तक नई बुकिंग और चेक-इन अवरुद्ध रहेंगे।',
      'Failed host lookup': 'होस्ट लुकअप विफल',
      'Failed to grant health permissions. Please enable them to sync data.':
          'स्वास्थ्य संबंधी अनुमतियाँ प्रदान करने में विफल। कृपया डेटा सिंक्रनाइज़ करने के लिए उन्हें सक्षम करें।',
      'Failed to grant medical access permissions.':
          'चिकित्सा संबंधी पहुँच की अनुमति देने में विफल।',
      'Failed to load trends': 'रुझान लोड करने में विफल',
      'Fair': 'गोरा',
      'Falling back to sequential fetching.':
          'क्रमिक रूप से डेटा प्राप्त करने पर वापस लौटना।',
      'Fantastic effort! You\'ve achieved your goal.':
          'शानदार प्रयास! आपने अपना लक्ष्य हासिल कर लिया है।',
      'Fat': 'मोटा',
      'Fat-free weight': 'वसा रहित वजन',
      'Feb': 'फ़रवरी',
      'Female': 'महिला',
      'Finalized': 'अंतिम रूप दिया',
      'Finish later': 'बाद में समाप्त करें',
      'Finish workout?': 'वर्कआउट खत्म?',
      'Fire': 'आग',
      'Fit the whole report inside the frame. Tap text to focus; keep labels and numbers sharp and glare-free.':
          'पूरी रिपोर्ट को फ्रेम के अंदर फिट करें। टेक्स्ट पर टैप करके उसे फोकस करें; लेबल और नंबर स्पष्ट और चमक-रहित रखें।',
      'Fitness App Synced': 'फिटनेस ऐप सिंक्रोनाइज़ हो गया',
      'Flagged': 'चिह्नित किए गए',
      'Flash is not available on this camera.':
          'इस कैमरे में फ्लैश की सुविधा उपलब्ध नहीं है।',
      'Flask': 'फ्लास्क',
      'Forearms': 'अग्र-भुजाओं',
      'Forgot Password?': 'पासवर्ड भूल गए?',
      'Forward 10 seconds': '10 सेकंड आगे बढ़ाएं',
      'Fri': 'शुक्र',
      'Friday': 'शुक्रवार',
      'From Exercise Library': 'व्यायाम पुस्तकालय से',
      'Front': 'सामने',
      'Full': 'भरा हुआ',
      'Full Name': 'पूरा नाम',
      'Full body': 'पूरा शरीर',
      'Full gym': 'पूरा जिम',
      'Full legal name': 'पूर्ण कानूनी नाम',
      'Full name': 'पूरा नाम',
      'Full-body training': 'संपूर्ण शरीर प्रशिक्षण',
      'GET': 'पाना',
      'GOAL ACHIEVED': 'लक्ष्य प्राप्त हुआ',
      'GYM': 'जिम',
      'GYM ACTIVE': 'जिम एक्टिव',
      'GYM CHECK-IN': 'जिम चेक-इन',
      'Gender': 'लिंग',
      'General fitness': 'सामान्य फिटनेस',
      'Generate a meal plan': 'भोजन योजना तैयार करें',
      'Generate a plan for today': 'आज के लिए एक योजना बनाएं',
      'Gentle alerts when it\'s time to rest.':
          'आराम करने का समय होने पर हल्की सूचना।',
      'Get Started': 'शुरू हो जाओ',
      'Glucose level': 'ग्लूकोज स्तर',
      'Glutes': 'नितंब',
      'Go back': 'वापस जाओ',
      'Go to your Profile tab': 'अपने प्रोफ़ाइल टैब पर जाएं',
      'Goal': 'लक्ष्य',
      'Goals saved on this device, but couldn\'t sync to the server.':
          'इस डिवाइस पर गोल सेव हो गए हैं, लेकिन सर्वर से सिंक नहीं हो पाए।',
      'Goals saved successfully!': 'गोल सफलतापूर्वक सेव हो गए!',
      'Good': 'अच्छा',
      'Good Afternoon': 'शुभ दोपहर',
      'Good Evening': 'शुभ संध्या',
      'Good Morning': 'शुभ प्रभात',
      'Google': 'गूगल',
      'Google Fit Setup Guide': 'गूगल फिट सेटअप गाइड',
      'Google Fit Sync Steps': 'गूगल फिट सिंक स्टेप्स',
      'Google Health Connect is required to securely aggregate and sync your health records.':
          'आपके स्वास्थ्य संबंधी रिकॉर्ड को सुरक्षित रूप से एकत्रित और सिंक्रनाइज़ करने के लिए Google Health Connect आवश्यक है।',
      'Grant': 'अनुदान',
      'Grant all Read & Write Permissions requested':
          'अनुरोधित सभी पढ़ने और लिखने की अनुमतियाँ प्रदान करें',
      'Great': 'महान',
      'Gym': 'जिम',
      'Gym Check-in': 'जिम चेक-इन',
      'Gym access': 'जिम तक पहुंच',
      'HEALTH': 'स्वास्थ्य',
      'HEALTH & WELLNESS': 'स्वास्थ्य और कल्याण',
      'HEIGHT': 'ऊंचाई',
      'Hamstrings': 'हैमस्ट्रिंग',
      'Head/neck': 'सिर/गर्दन',
      'Headers: Authorization: Bearer [token]': 'हेडर: प्राधिकरण: बियरर [टोकन]',
      'Health Connect': 'स्वास्थ्य कनेक्ट',
      'Health Connect Installed': 'हेल्थ कनेक्ट स्थापित किया गया',
      'Health Connect Required': 'हेल्थ कनेक्ट आवश्यक है',
      'Health Connect app is not installed on this device.':
          'इस डिवाइस पर हेल्थ कनेक्ट ऐप इंस्टॉल नहीं है।',
      'Health Connect is connected. To view health metrics, please ensure a supported fitness app (like Google Fit) is active and syncing with Health Connect.':
          'हेल्थ कनेक्ट चालू है। स्वास्थ्य संबंधी आंकड़े देखने के लिए, कृपया सुनिश्चित करें कि कोई समर्थित फिटनेस ऐप (जैसे Google Fit) सक्रिय है और हेल्थ कनेक्ट के साथ सिंक हो रहा है।',
      'Health Connect permissions are already granted.':
          'हेल्थ कनेक्ट की अनुमतियाँ पहले ही प्रदान की जा चुकी हैं।',
      'Health Data Available': 'स्वास्थ्य संबंधी आंकड़े उपलब्ध हैं',
      'Health Data Collection': 'स्वास्थ्य डेटा संग्रह',
      'Health Reports': 'स्वास्थ्य रिपोर्ट',
      'Health Sync Debugger': 'स्वास्थ्य सिंक डीबगर',
      'Health database synced!': 'स्वास्थ्य डेटाबेस सिंक्रनाइज़ हो गया!',
      'Health goals': 'स्वास्थ्य लक्ष्य',
      'Health report': 'स्वास्थ्य रपट',
      'Health report deleted.': 'स्वास्थ्य रिपोर्ट हटा दी गई।',
      'Health report updated.': 'स्वास्थ्य रिपोर्ट अपडेट कर दी गई है।',
      'Health report uploaded': 'स्वास्थ्य रिपोर्ट अपलोड कर दी गई है',
      'Health services connected. Your data will appear shortly.':
          'स्वास्थ्य सेवाएं कनेक्ट हो गई हैं। आपका डेटा जल्द ही दिखाई देगा।',
      'HealthKit initial sync is taking longer than 20 seconds.':
          'HealthKit का प्रारंभिक सिंक होने में 20 सेकंड से अधिक समय लग रहा है।',
      'HealthService configured successfully.':
          'हेल्थ सर्विस सफलतापूर्वक कॉन्फ़िगर हो गई है।',
      'Heart Alert': 'हार्ट अलर्ट',
      'Heart Condition': 'हृदय रोग',
      'Heart Rate': 'हृदय दर',
      'Heart Rate Pulse': 'हृदय गति नाड़ी',
      'Height': 'ऊंचाई',
      'Height (cm)': 'ऊंचाई (सेमी)',
      'Helpful reminders to support consistent sleep':
          'नियमित नींद के लिए उपयोगी अनुस्मारक',
      'Hi! I\'m your fitness coach. ✨ Ask me about sleep, nutrition, hydration, or general fitness tips.':
          'नमस्ते! मैं आपकी फिटनेस कोच हूँ। ✨ मुझसे नींद, पोषण, हाइड्रेशन या सामान्य फिटनेस टिप्स के बारे में पूछें।',
      'Hide from my summary': 'मेरी सारांश से छिपाएँ',
      'Hide from summary': 'सारांश से छिपाएँ',
      'Hide this session?': 'क्या आप इस सत्र को छिपाना चाहते हैं?',
      'High': 'उच्च',
      'High blood pressure management': 'उच्च रक्तचाप का प्रबंधन',
      'High-protein': 'उच्च प्रोटीन',
      'Hip': 'कूल्हा',
      'History': 'इतिहास',
      'Home': 'घर',
      'Home Facility': 'गृह सुविधा',
      'How are you feeling today?': 'आज आप कैसा महसूस कर रहे हैं?',
      'How can I sleep better?': 'मैं बेहतर नींद कैसे ले सकता हूँ?',
      'How do you feel after today’s workout?':
          'आज के वर्कआउट के बाद आपको कैसा लग रहा है?',
      'How to burn 500 kcal?': '500 किलो कैलोरी कैसे बर्न करें?',
      'How was your workout?': 'आपका वर्कआउट कैसा रहा?',
      'Hydration Alert': 'हाइड्रेशन अलर्ट',
      'Hydration Alerts': 'हाइड्रेशन अलर्ट',
      'Hydration Reminders': 'हाइड्रेशन रिमाइंडर',
      'Hydration Tracker': 'हाइड्रेशन ट्रैकर',
      'Hydration Trends': 'हाइड्रेशन ट्रेंड्स',
      'Hypertension': 'उच्च रक्तचाप',
      'I agree to the': 'मैं करने के लिए सहमत हूं',
      'I consent to my employer receiving only anonymized, aggregate program participation statistics — never my individual health data.':
          'मैं इस बात से सहमत हूं कि मेरे नियोक्ता को केवल गुमनाम, समग्र कार्यक्रम भागीदारी के आंकड़े प्राप्त हों - मेरे व्यक्तिगत स्वास्थ्य डेटा कभी नहीं।',
      'I couldn\'t process that.': 'मुझे यह बात समझ नहीं आई।',
      'I don\'t have any of these conditions':
          'मुझे इनमें से कोई भी समस्या नहीं है।',
      'I explicitly consent to allow wellnessconnect to access my secure medical records.':
          'मैं स्पष्ट रूप से वेलनेसकनेक्ट को अपने सुरक्षित चिकित्सा रिकॉर्ड तक पहुंचने की अनुमति देता हूं।',
      'I forgot to book a slot': 'मैं स्लॉट बुक करना भूल गया था',
      'I need help booking a facility slot.':
          'मुझे किसी सुविधा केंद्र में बुकिंग कराने में मदद चाहिए।',
      'I would like my care team to review a suitable program for me.':
          'मैं चाहूँगा कि मेरी देखभाल करने वाली टीम मेरे लिए एक उपयुक्त कार्यक्रम की समीक्षा करे।',
      'I\'m having trouble connecting right now. Please try again.':
          'मुझे अभी कनेक्ट करने में समस्या हो रही है। कृपया पुनः प्रयास करें।',
      'IN': 'में',
      'IN REVIEW': 'समीक्षा में',
      'Immunization': 'प्रतिरक्षा',
      'Import PDF': 'पीडीएफ आयात करें',
      'Import Screenshot': 'स्क्रीनशॉट आयात करें',
      'In an emergency, tap SOS to notify contacts, or call services directly from the cards above.':
          'आपातकालीन स्थिति में, संपर्कों को सूचित करने के लिए SOS टैप करें, या ऊपर दिए गए कार्ड से सीधे सेवाओं को कॉल करें।',
      'Include food and quantity for a better estimate.':
          'बेहतर अनुमान के लिए भोजन की मात्रा और भोजन शुल्क भी शामिल करें।',
      'Individual': 'व्यक्ति',
      'Initialized/updated local nutrition cache from API':
          'API से स्थानीय पोषण कैश को आरंभ/अद्यतन किया गया',
      'Initializing secure container...':
          'सुरक्षित कंटेनर प्रारंभ किया जा रहा है...',
      'Inner thighs': 'अंदरूनी जांघे',
      'Instant Check-in': 'तुरंत चेक-इन',
      'Instant check-in': 'तुरंत चेक-इन',
      'Intense exercise 4-5 times a week, high daily steps.':
          'सप्ताह में 4-5 बार गहन व्यायाम, प्रतिदिन अधिक पैदल चलना।',
      'Intensity': 'तीव्रता',
      'Intermediate': 'मध्यवर्ती',
      'Is your workout complete?': 'क्या आपका वर्कआउट पूरा हो गया?',
      'Issue raised to the facility manager.':
          'यह मामला सुविधा प्रबंधक के समक्ष उठाया गया।',
      'JSON payload copied to clipboard!':
          'JSON पेलोड क्लिपबोर्ड पर कॉपी हो गया!',
      'Jan': 'जनवरी',
      'John Doe': 'जॉन डो',
      'Join Challenge': 'चुनौती में शामिल हों',
      'Join a challenge below to start tracking your progress & earning rewards!':
          'अपनी प्रगति पर नज़र रखने और पुरस्कार अर्जित करने के लिए नीचे दिए गए चैलेंज में शामिल हों!',
      'Join company challenges and follow verified scores':
          'कंपनी की चुनौतियों में शामिल हों और सत्यापित स्कोर देखें',
      'Jul': 'जुलाई',
      'Jul 12': '12 जुलाई',
      'Jun': 'जून',
      'Just now': 'बस अब ',
      'KG': 'केजी',
      'Keep going, you are close to hitting your goal!':
          'आगे बढ़ते रहो, तुम अपने लक्ष्य के बहुत करीब हो!',
      'Keep program': 'कार्यक्रम जारी रखें',
      'Keep working': 'काम करते रहो',
      'Keto': 'कीटो',
      'Knee': 'घुटना',
      'LBS': 'एलबीएस',
      'Lab Results': 'प्रयोगशाला परिणाम',
      'Label': 'लेबल',
      'Laboratory': 'प्रयोगशाला',
      'Language': 'भाषा',
      'Latest': 'नवीनतम',
      'Latest records': 'नवीनतम रिकॉर्ड',
      'Latest report': 'नवीनतम रिपोर्ट',
      'Lats': 'लाट्स',
      'Leaderboard changes and completion status':
          'लीडरबोर्ड में बदलाव और पूर्णता की स्थिति',
      'Less progress': 'कम प्रगति',
      'Library': 'पुस्तकालय',
      'Lifestyle & Goals': 'जीवनशैली और लक्ष्य',
      'Light': 'रोशनी',
      'Link Apple or Google first': 'पहले Apple या Google को लिंक करें',
      'Lipid Panel': 'लिपिड पैनल',
      'Lipid Panel (Cardiovascular Screen)': 'लिपिड पैनल (हृदय संबंधी जांच)',
      'Live': 'रहना',
      'Live Activities are turned off for Wellnessconnect. Your workout remains active, but turn them on in iPhone Settings to keep the timer visible outside the app.':
          'वेलनेसकनेक्ट के लिए लाइव एक्टिविटीज़ बंद हैं। आपका वर्कआउट जारी रहेगा, लेकिन ऐप के बाहर टाइमर को देखने के लिए iPhone सेटिंग्स में जाकर इन्हें चालू करें।',
      'Loading your plan-aware weekly summary…':
          'आपकी योजना के अनुरूप साप्ताहिक सारांश लोड हो रहा है…',
      'Local health service water state reset.':
          'स्थानीय स्वास्थ्य सेवा जल स्थिति का पुनर्निर्धारण।',
      'Log': 'लकड़ी का लट्ठा',
      'Log In': 'लॉग इन करें',
      'Log Meal': 'लॉग मील',
      'Log a meal ›': 'भोजन का रिकॉर्ड दर्ज करें ›',
      'Log at least 2000 ml of water daily for 7 consecutive days.':
          'लगातार 7 दिनों तक प्रतिदिन कम से कम 2000 मिलीलीटर पानी का सेवन करें।',
      'Log deleted successfully': 'लॉग सफलतापूर्वक हटा दिया गया',
      'Log meals to see your trend.':
          'अपने खाने के पैटर्न को रिकॉर्ड करें ताकि आप अपने रुझान को देख सकें।',
      'Log updated successfully': 'लॉग सफलतापूर्वक अपडेट हो गया',
      'Log water & watch the waves rise':
          'पानी में लॉग लगाएं और लहरों को उठते हुए देखें',
      'Log your lunch': 'अपने लंच को रिकॉर्ड करें',
      'Logged Date': 'लॉग की गई तिथि',
      'Logged Day': 'लॉग किया गया दिन',
      'Login with SSO': 'एसएसओ के साथ लॉगिन करें',
      'Lose weight': 'वजन घटाएं',
      'Low': 'कम',
      'Low-carb': 'कम कार्बोहाइड्रेट वाला',
      'Lower back': 'पीठ का निचला हिस्सा',
      'Lowercase Letter': 'छोटा अक्षर',
      'M': 'एम',
      'MEASUREMENT DATE': 'माप की तिथि',
      'MEMBER OF': 'के सदस्य',
      'Make Changes': 'बदलाव करें',
      'Make sure the report is flat, bright, and in focus, then try again.':
          'सुनिश्चित करें कि रिपोर्ट सपाट, चमकदार और स्पष्ट हो, फिर दोबारा प्रयास करें।',
      'Male': 'पुरुष',
      'Manage AI workout-report sharing':
          'एआई वर्कआउट-रिपोर्ट शेयरिंग को मैनेज करें',
      'Manual Log': 'मैन्युअल लॉग',
      'Manual Logging': 'मैन्युअल लॉगिंग',
      'Manual measurement': 'मैनुअल माप',
      'Mar': 'मार्च',
      'Mark complete if this exercise was finished':
          'यदि यह अभ्यास पूरा हो गया है तो पूर्ण के रूप में चिह्नित करें।',
      'Mark this exercise when it is finished':
          'यह अभ्यास पूरा होने पर इसे चिह्नित करें',
      'Match device setting': 'डिवाइस सेटिंग का मिलान करें',
      'May': 'मई',
      'Meal': 'खाना',
      'Meal Plan': 'भोजन की योजना',
      'Meal Tracker': 'भोजन ट्रैकर',
      'Meal added to today’s tracker.':
          'आज के ट्रैकर में भोजन जोड़ दिया गया है।',
      'Meal added to your tracker.': 'आपका भोजन ट्रैकर में जोड़ दिया गया है।',
      'Meals, portions & macros': 'भोजन, मात्रा और मैक्रोज़',
      'Measurement': 'माप',
      'Measurement changes': 'माप में परिवर्तन',
      'Measurements': 'मापन',
      'Measurements are shown separately from participation and time elapsed.':
          'माप को सहभागिता और व्यतीत समय से अलग दिखाया गया है।',
      'Measurements compared': 'मापों की तुलना की गई',
      'Medical & Clinical Records': 'चिकित्सा एवं नैदानिक ​​अभिलेख',
      'Medical Data Sharing': 'चिकित्सा डेटा साझाकरण',
      'Medical Health Profile': 'चिकित्सा स्वास्थ्य प्रोफ़ाइल',
      'Medical Records': 'मेडिकल रिकॉर्ड',
      'Medical records access authorized!':
          'चिकित्सा अभिलेखों तक पहुंच अधिकृत है!',
      'Medical records consent revoked and data cleared.':
          'चिकित्सा रिकॉर्ड के लिए दी गई सहमति रद्द कर दी गई है और डेटा हटा दिया गया है।',
      'Medical records consent revoked.':
          'चिकित्सा रिकॉर्ड संबंधी सहमति रद्द कर दी गई है।',
      'Medifit': 'मेडिफिट',
      'Meditation': 'ध्यान',
      'Medium Strength': 'मध्यम शक्ति',
      'Mednovations': 'मेडनोवेशन्स',
      'Member chose to keep working after leaving the geofence.':
          'सदस्य ने भौगोलिक सीमा से बाहर निकलने के बाद भी काम जारी रखने का विकल्प चुना।',
      'Member chose to keep working after the booked slot ended.':
          'सदस्य ने निर्धारित समय समाप्त होने के बाद भी काम जारी रखने का विकल्प चुना।',
      'Member chose to keep working after the hourly prompt.':
          'सदस्य ने निर्धारित समय सीमा समाप्त होने के बाद भी काम जारी रखने का विकल्प चुना।',
      'Member chose to keep working from the workout notification.':
          'सदस्य ने वर्कआउट नोटिफिकेशन से काम जारी रखने का विकल्प चुना।',
      'Member corrected': 'सदस्य ने सुधार किया',
      'Member-entered': 'सदस्य द्वारा दर्ज किया गया',
      'Metabolic age': 'चयापचय आयु',
      'Metric': 'मीट्रिक',
      'Mind': 'दिमाग',
      'Mindfulness': 'सचेतन',
      'Missed check-in': 'चेक-इन छूट गया',
      'Moderate': 'मध्यम',
      'Mon': 'सोमवार',
      'Monday': 'सोमवार',
      'Month': 'महीना',
      'Month-by-Month Logs (Last 3 Months)': 'माहवार लॉग (पिछले 3 महीने)',
      'Monthly': 'महीने के',
      'Mood': 'मनोदशा',
      'Mood Check-in': 'मनोदशा की जाँच',
      'More': 'अधिक',
      'More progress': 'और प्रगति',
      'Morning briefing summarizing stats and goals':
          'सुबह की संक्षिप्त बैठक में आंकड़ों और लक्ष्यों का सारांश प्रस्तुत किया गया।',
      'Move': 'कदम',
      'Movement nudges if you remain inactive':
          'निष्क्रिय रहने पर हलचल से संकेत मिलते हैं',
      'Much better': 'काफी बेहतर',
      'Much worse': 'बहुत खराब',
      'Muscle Gain': 'मांसपेशियों में वृद्धि',
      'Muscle mass': 'मांसपेशियों',
      'My Actions': 'मेरी कार्रवाई',
      'My Care Program': 'मेरा देखभाल कार्यक्रम',
      'My upcoming bookings': 'मेरी आगामी बुकिंग',
      'NUTRITION': 'पोषण',
      'Name': 'नाम',
      'Neutral': 'तटस्थ',
      'New': 'नया',
      'New Password': 'नया पासवर्ड',
      'New broadcast': 'नया प्रसारण',
      'New conversation': 'नई बातचीत',
      'New password': 'नया पासवर्ड',
      'Newer report': 'नई रिपोर्ट',
      'Next': 'अगला',
      'Next page': 'अगला पृष्ठ',
      'No': 'नहीं',
      'No Active Challenges': 'कोई सक्रिय चुनौतियाँ नहीं',
      'No Onboarding Data': 'ऑनबोर्डिंग डेटा उपलब्ध नहीं है',
      'No actions are scheduled today.': 'आज कोई कार्यक्रम निर्धारित नहीं है।',
      'No active challenges': 'कोई सक्रिय चुनौतियाँ नहीं',
      'No assigned checklist was stored for this session.':
          'इस सत्र के लिए कोई निर्धारित चेकलिस्ट संग्रहीत नहीं की गई थी।',
      'No change from the earlier report':
          'पिछली रिपोर्ट में कोई बदलाव नहीं हुआ है।',
      'No checklist': 'कोई चेकलिस्ट नहीं',
      'No comparison yet': 'अभी तक कोई तुलना नहीं हुई है',
      'No comparisons yet. Choose Compare Reports to create one.':
          'अभी तक कोई तुलना उपलब्ध नहीं है। तुलना रिपोर्ट बनाने के लिए &#39;तुलना रिपोर्ट&#39; चुनें।',
      'No daily schedule entries are available for this plan.':
          'इस प्लान के लिए दैनिक शेड्यूल प्रविष्टियाँ उपलब्ध नहीं हैं।',
      'No email on file': 'हमारे पास ईमेल पता दर्ज नहीं है।',
      'No emergency contacts yet': 'अभी तक कोई आपातकालीन संपर्क नहीं है',
      'No exercise videos are available yet.':
          'अभी तक कोई व्यायाम वीडियो उपलब्ध नहीं है।',
      'No exercises are fully completed. You can still check out.':
          'कोई भी अभ्यास पूरी तरह से संपन्न नहीं हुआ है। आप फिर भी चेकआउट कर सकते हैं।',
      'No expected actions have been generated yet':
          'अभी तक कोई अपेक्षित कार्रवाई उत्पन्न नहीं हुई है',
      'No extra exercises added.': 'कोई अतिरिक्त व्यायाम नहीं जोड़े गए हैं।',
      'No facilities are linked to your organisation.':
          'आपकी संस्था से कोई सुविधा संबद्ध नहीं है।',
      'No health measurements were found in that PDF. Try a clear screenshot or scan.':
          'उस पीडीएफ में स्वास्थ्य संबंधी कोई माप नहीं मिला। कृपया स्पष्ट स्क्रीनशॉट या स्कैन भेजकर देखें।',
      'No health reports yet. Add one from Update Your Health.':
          'अभी तक कोई स्वास्थ्य रिपोर्ट उपलब्ध नहीं है। कृपया &#39;अपडेट योर हेल्थ&#39; से एक रिपोर्ट जोड़ें।',
      'No health services connected. You can log your metrics manually below:':
          'कोई स्वास्थ्य सेवा उपलब्ध नहीं है। आप नीचे दिए गए लिंक पर जाकर अपने डेटा को मैन्युअल रूप से लॉग कर सकते हैं:',
      'No historical logs available for this range':
          'इस श्रेणी के लिए कोई ऐतिहासिक लॉग उपलब्ध नहीं हैं।',
      'No items recorded.': 'कोई वस्तु दर्ज नहीं की गई।',
      'No local onboarding data has been saved yet. Complete onboarding or save a profile first.':
          'अभी तक कोई स्थानीय ऑनबोर्डिंग डेटा सहेजा नहीं गया है। कृपया पहले ऑनबोर्डिंग प्रक्रिया पूरी करें या प्रोफ़ाइल सहेजें।',
      'No logs recorded yet. Tap a quick amount to start.':
          'अभी तक कोई लॉग रिकॉर्ड नहीं हुआ है। शुरू करने के लिए एक छोटी सी राशि टैप करें।',
      'No matching exercises.': 'मिलान करने वाले अभ्यास नहीं।',
      'No medical records found in device database.':
          'डिवाइस डेटाबेस में कोई मेडिकल रिकॉर्ड नहीं मिला।',
      'No new guidance has been published.':
          'कोई नया दिशानिर्देश प्रकाशित नहीं किया गया है।',
      'No notifications yet': 'अभी तक कोई सूचना नहीं मिली है',
      'No objectives recorded.': 'कोई लक्ष्य दर्ज नहीं किया गया।',
      'No preference': 'कोई वरीयता नहीं',
      'No previous programs yet.': 'अभी तक कोई पूर्व कार्यक्रम नहीं हैं।',
      'No published guidance is available for this period.':
          'इस अवधि के लिए कोई प्रकाशित दिशानिर्देश उपलब्ध नहीं हैं।',
      'No readable text was found in that PDF. Try a clear screenshot or scan.':
          'उस पीडीएफ में कोई पठनीय पाठ नहीं मिला। कृपया स्पष्ट स्क्रीनशॉट या स्कैन करके देखें।',
      'No rear camera is available on this device.':
          'इस डिवाइस में रियर कैमरा उपलब्ध नहीं है।',
      'No refresh token found': 'कोई रिफ्रेश टोकन नहीं मिला',
      'No sync logs available yet':
          'अभी तक कोई सिंक्रोनाइज़ेशन लॉग उपलब्ध नहीं हैं।',
      'No videos match your search.':
          'आपकी खोज से मेल खाने वाले कोई वीडियो नहीं हैं।',
      'No workout assigned today. You can still check out when you finish.':
          'आज कोई वर्कआउट निर्धारित नहीं है। पूरा होने पर आप चेकआउट कर सकते हैं।',
      'No workout checklist was assigned for this session.':
          'इस सत्र के लिए कोई वर्कआउट चेकलिस्ट निर्धारित नहीं की गई थी।',
      'No workout reports yet': 'अभी तक कोई वर्कआउट रिपोर्ट नहीं है',
      'Non-binary': 'गैर-बाइनरी',
      'None selected': 'कोई चयनित नहीं',
      'Normal': 'सामान्य',
      'Not completed': 'पूरा नहीं हुआ',
      'Not now': 'अभी नहीं',
      'Not recorded': 'रिकॉर्ड नहीं किया गया',
      'Not recorded in either report':
          'दोनों रिपोर्टों में इसका उल्लेख नहीं है।',
      'Not set': 'सेट नहीं',
      'Not sure yet': 'अभी पक्का नहीं है',
      'Notification': 'अधिसूचना',
      'Notification Settings': 'अधिसूचना सेटिंग्स',
      'Notifications': 'सूचनाएं',
      'NotoSansDevanagari': 'नोटोसंदेवनागरी',
      'NotoSansKannada': 'NotoSansKannada',
      'Nov': 'नवंबर',
      'Numeric Digit': 'संख्यात्मक अंक',
      'Nutri': 'न्यूट्री',
      'Nutrition': 'पोषण',
      'Nutrition Plan': 'पोषण योजना',
      'Nutrition trend graphs are not supported by the backend yet.':
          'पोषण संबंधी रुझान ग्राफ अभी तक बैकएंड द्वारा समर्थित नहीं हैं।',
      'OCR TRANSCRIPT': 'ओसीआर प्रतिलेख',
      'OK': 'ठीक है',
      'OR CONTINUE WITH': 'या जारी रखें',
      'OR SIGN UP WITH': 'या इसके साथ साइन अप करें',
      'ORGANIZATION': 'संगठन',
      'OTP sent to email': 'ईमेल पर ओटीपी भेजा गया',
      'Obese': 'मोटा',
      'Oct': 'अक्टूबर',
      'Okay': 'ठीक है',
      'Older report': 'पुरानी रिपोर्ट',
      'Onboarding Data': 'ऑनबोर्डिंग डेटा',
      'Open Camera': 'कैमरा खोलें',
      'Open Fitness Coach': 'ओपन फिटनेस कोच',
      'Open Google Fit app on your device':
          'अपने डिवाइस पर Google Fit ऐप खोलें',
      'Open Settings': 'खुली सेटिंग',
      'Open Settings (Gear Icon)': 'सेटिंग्स खोलें (गियर आइकन)',
      'Open checkout': 'चेकआउट खोलें',
      'Open today': 'आज खुला',
      'Open tracker': 'ओपन ट्रैकर',
      'Optimize. Sync. Thrive.':
          'अनुकूलन करें। समन्वय स्थापित करें। सफलता प्राप्त करें।',
      'Optional': 'वैकल्पिक',
      'Or sign in with a code instead': 'या फिर कोड से साइन इन करें',
      'Organization': 'संगठन',
      'Other': 'अन्य',
      'Outdoor': 'बाहरी',
      'Overall experience': 'समग्र अनुभव',
      'Overview': 'अवलोकन',
      'Overweight': 'अधिक वजन',
      'Owns your program and clinical review':
          'आपके प्रोग्राम और क्लिनिकल रिव्यू का स्वामित्व रखता है',
      'PASSWORD': 'पासवर्ड',
      'PASSWORD ADVISOR': 'पासवर्ड सलाहकार',
      'PATCH': 'पैबंद',
      'PDF document': 'पीडीएफ दस्तावेज़',
      'PDF import': 'पीडीएफ आयात',
      'PDF ready. Choose Save to Files or share it.':
          'पीडीएफ फाइल तैयार है। इसे सेव टू फाइल्स चुनें या शेयर करें।',
      'PERSONAL DETAILS': 'व्यक्तिगत विवरण',
      'PLAN TIMELINE': 'योजना की समयरेखा',
      'POST': 'डाक',
      'PREFERENCES': 'प्राथमिकताएँ',
      'PREVIOUS': 'पहले का',
      'PUT': 'रखना',
      'Pain note (optional)': 'दर्द संबंधी टिप्पणी (वैकल्पिक)',
      'Password must be at least 6 characters.':
          'पासवर्ड कम से कम 6 अंकों का होना चाहिए।',
      'Password must be at least 8 characters':
          'पासवर्ड कम से कम 8 वर्णों का होना चाहिए',
      'Password reset successful': 'पासवर्ड रीसेट सफल रहा',
      'Pause': 'विराम',
      'Paused and future days are excluded from expected totals.':
          'स्थगित और आगामी दिनों को अपेक्षित योग से बाहर रखा गया है।',
      'Pending': 'लंबित',
      'People notified when you trigger SOS':
          'SOS ट्रिगर करने पर लोगों को सूचित किया जाएगा',
      'Percentage fat': 'वसा का प्रतिशत',
      'Period: day · week · month': 'अवधि: दिन · सप्ताह · महीना',
      'Permissions & Reminders': 'अनुमतियाँ और अनुस्मारक',
      'Permissions Granted': 'अनुमतियाँ प्रदान की गईं',
      'Permissions Required': 'अनुमतियाँ आवश्यक हैं',
      'Personal health advisor': 'व्यक्तिगत स्वास्थ्य सलाहकार',
      'Personalized advice from your AI Wellness Buddy':
          'आपके एआई वेलनेस बडी से व्यक्तिगत सलाह',
      'Personalizing Experience': 'अनुभव को वैयक्तिकृत करना',
      'Phone number': 'फ़ोन नंबर',
      'Photo unavailable': 'फोटो उपलब्ध नहीं है',
      'Physical job or professional athlete training daily.':
          'शारीरिक श्रम करने वाले कर्मचारी या पेशेवर एथलीट जो प्रतिदिन प्रशिक्षण लेते हैं।',
      'Physician completion summary': 'चिकित्सक द्वारा पूर्णता का सारांश',
      'Pilates': 'पिलेट्स',
      'Plan details': 'योजना का विवरण',
      'Plan focus': 'योजना फोकस',
      'Plan summary': 'योजना का सारांश',
      'Play': 'खेल',
      'Please add the food and quantity you ate.':
          'कृपया आपने जो खाना खाया और उसकी मात्रा बताएं।',
      'Please agree to the Terms of Service & Privacy Policy':
          'कृपया सेवा की शर्तों और गोपनीयता नीति से सहमत हों।',
      'Please agree to the required consents and sign your name':
          'कृपया आवश्यक सहमति दें और अपने हस्ताक्षर करें।',
      'Please choose your organization.': 'कृपया अपना संगठन चुनें।',
      'Please describe what you ate and how much.':
          'कृपया बताएं कि आपने क्या खाया और कितनी मात्रा में खाया।',
      'Please enter a password': 'कृपया पासवर्ड दर्ज करें',
      'Please enter a valid email': 'कृपया एक मान्य ईमेल दर्ज करें',
      'Please enter a valid email address.':
          'कृपया एक मान्य ईमेल पता प्रविष्ट करें।',
      'Please enter a valid number': 'कृपया सही अंक दर्ज करें',
      'Please enter a valid volume amount': 'कृपया एक वैध मात्रा दर्ज करें',
      'Please enter the 6-digit OTP code.':
          'कृपया 6 अंकों का ओटीपी कोड दर्ज करें।',
      'Please enter the 6-digit code.': 'कृपया 6 अंकों का कोड दर्ज करें।',
      'Please enter your full name': 'कृपया अपना पूरा नाम दर्ज करें',
      'Please enter your height': 'कृपया अपनी ऊंचाई दर्ज करें',
      'Please enter your name': 'कृपया अपना नाम दर्ज करें',
      'Please enter your password': 'अपना पासवर्ड दर्ज करें',
      'Please enter your weight': 'कृपया अपना वज़न दर्ज करें',
      'Please select a condition or check the box below':
          'कृपया कोई शर्त चुनें या नीचे दिए गए बॉक्स पर निशान लगाएं',
      'Please select your company and home facility':
          'कृपया अपनी कंपनी और घरेलू सुविधा का चयन करें',
      'Please select your date of birth': 'कृपया अपनी जन्मतिथि चुनें',
      'Please select your gender': 'कृपया अपना लिंग चुनें',
      'Please take the report photo again.':
          'कृपया रिपोर्ट की फोटो दोबारा लें।',
      'Please try again in a moment.': 'कृपया थोड़ी देर बाद पुनः प्रयास करें।',
      'Police': 'पुलिस',
      'Preferred cuisine (optional)': 'पसंदीदा व्यंजन (वैकल्पिक)',
      'Preparing': 'तैयारी',
      'Preparing instant check-in': 'इंस्टेंट चेक-इन की तैयारी चल रही है',
      'Preparing your personalized dashboard...':
          'आपका व्यक्तिगत डैशबोर्ड तैयार किया जा रहा है...',
      'Preview': 'पूर्व दर्शन',
      'Previous bookings': 'पिछली बुकिंग',
      'Previous page': 'पिछला पृष्ठ',
      'Previous step': 'पिछला चरण',
      'Previously visited': 'पहले दौरा किया गया',
      'Primary Health Goals': 'प्राथमिक स्वास्थ्य लक्ष्य',
      'Privacy Policy': 'गोपनीयता नीति',
      'Profile': 'प्रोफ़ाइल',
      'Profile updated successfully': 'प्रोफ़ाइल सफलतापूर्वक अपडेट हो गई',
      'Program history': 'कार्यक्रम का इतिहास',
      'Program objectives': 'कार्यक्रम के उद्देश्य',
      'Program paused': 'कार्यक्रम स्थगित',
      'Program time elapsed': 'कार्यक्रम का समय समाप्त हो गया',
      'Program timeline': 'कार्यक्रम की समयरेखा',
      'Progress': 'प्रगति',
      'Progress & Trends': 'प्रगति और रुझान',
      'Progress report': 'प्रगति रिपोर्ट',
      'Progress timeline': 'प्रगति समयरेखा',
      'Progress: 5/7 days completed': 'प्रगति: 7 में से 5 दिन पूरे हुए',
      'Protein': 'प्रोटीन',
      'Provide Explicit Consent': 'स्पष्ट सहमति प्रदान करें',
      'Provider': 'प्रदाता',
      'Provider:': 'प्रदाता:',
      'Published care-team guidance': 'प्रकाशित देखभाल-टीम दिशानिर्देश',
      'Published guidance': 'प्रकाशित मार्गदर्शन',
      'Pulse Rate': 'नब्ज़ दर',
      'QR scan': 'क्यूआर स्कैन',
      'QUICK ACCESS': 'त्वरित पहुँच',
      'Quadriceps': 'चतुशिरस्क',
      'Quest Diagnostics': 'क्वेस्ट डायग्नोस्टिक्स',
      'Quick Logging': 'त्वरित लॉगिंग',
      'Quick start': 'त्वरित शुरुआत',
      'REST': 'आराम',
      'REVIEW DUE': 'समीक्षा देय है',
      'REWARDS & CHALLENGES': 'पुरस्कार और चुनौतियाँ',
      'Raise booking issue': 'बुकिंग संबंधी समस्या उठाएँ',
      'Rate later': 'दर बाद में',
      'Rate limit hit during fallback fetch. Returning cached HealthData.':
          'फ़ॉलबैक फ़ेच के दौरान रेट लिमिट पार हो गई। कैश्ड हेल्थडेटा वापस किया जा रहा है।',
      'Rate limit hit during sleep fetch. Returning cached HealthData.':
          'स्लीप फ़ेच के दौरान रेट लिमिट पार हो गई। कैश्ड हेल्थडेटा वापस किया जा रहा है।',
      'Rate limit hit during steps fetch. Returning cached HealthData.':
          'चरणों को प्राप्त करने के दौरान दर सीमा पार हो गई। कैश किया गया स्वास्थ्य डेटा वापस किया जा रहा है।',
      'Rate limit or quota hit during batch fetch. Returning cached HealthData.':
          'बैच फ़ेच के दौरान दर सीमा या कोटा सीमा पार हो गई। कैश्ड हेल्थडेटा वापस किया जा रहा है।',
      'Rate limit or quota hit during daily records batch. Returning cached list.':
          'दैनिक रिकॉर्ड बैच के दौरान दर सीमा या कोटा सीमा पार हो गई। कैश्ड सूची वापस भेजी जा रही है।',
      'Rate limit or quota hit during today-only fetch. Returning cached records.':
          'आज ही डेटा फ़ेच करने के दौरान रेट लिमिट या कोटा पूरा हो गया। कैश्ड रिकॉर्ड वापस किए जा रहे हैं।',
      'Raw JSON': 'रॉ JSON',
      'Read a PDF up to 10 MB and five pages.':
          '10 एमबी तक की और पांच पृष्ठों वाली पीडीएफ फाइल पढ़ें।',
      'Reading your report securely on this device':
          'इस डिवाइस पर अपनी रिपोर्ट को सुरक्षित रूप से पढ़ें',
      'Ready': 'तैयार',
      'Ready for your next rep': 'अगले अभ्यास सत्र के लिए तैयार हैं?',
      'Realtime reading': 'रीयलटाइम रीडिंग',
      'Reason': 'कारण',
      'Reason (optional)': 'कारण (वैकल्पिक)',
      'Receive a summary of today\'s health metrics.':
          'आज के स्वास्थ्य संबंधी आंकड़ों का सारांश प्राप्त करें।',
      'Receive personalized tips, metrics summary, and recommendations designed exactly for you.':
          'आपको विशेष रूप से आपके लिए तैयार किए गए व्यक्तिगत सुझाव, मेट्रिक्स सारांश और अनुशंसाएं प्राप्त होंगी।',
      'Recent activity': 'हाल की गतिविधि',
      'Recent check-ins': 'हाल ही में किए गए चेक-इन',
      'Recommended': 'अनुशंसित',
      'Recorded in one report only': 'केवल एक रिपोर्ट में दर्ज किया गया',
      'Recorded only in the earlier report':
          'पिछली रिपोर्ट में ही दर्ज किया गया',
      'Recorded only in the latest report':
          'केवल नवीनतम रिपोर्ट में दर्ज किया गया',
      'Recovery and rest.': 'स्वास्थ्य लाभ और विश्राम।',
      'Recovery note': 'रिकवरी नोट',
      'Refresh': 'ताज़ा करना',
      'Refresh check-in history': 'चेक-इन इतिहास रीफ़्रेश करें',
      'Refresh graph': 'ग्राफ़ को रीफ़्रेश करें',
      'Refresh library': 'लाइब्रेरी को रीफ़्रेश करें',
      'Reject': 'अस्वीकार करना',
      'Remind you to log water and reach your goals.':
          'आपको पानी का हिसाब रखने और अपने लक्ष्यों को प्राप्त करने की याद दिलाना।',
      'Reminders to log and meet your daily water goal':
          'अपने दैनिक पानी के लक्ष्य को पूरा करने और उसे दर्ज करने के लिए अनुस्मारक',
      'Remove': 'निकालना',
      'Remove extra exercise': 'अतिरिक्त व्यायाम हटा दें',
      'Remove last extra set': 'आखिरी अतिरिक्त सेट हटा दें',
      'Remove measurement': 'माप हटाएँ',
      'Replay': 'REPLAY',
      'Report Comparison': 'रिपोर्ट तुलना',
      'Report Library': 'रिपोर्ट लाइब्रेरी',
      'Report comparison': 'रिपोर्ट तुलना',
      'Reported BMI': 'रिपोर्ट किया गया बीएमआई',
      'Reported and app-calculated BMI are shown separately so their sources stay clear.':
          'रिपोर्ट किए गए और ऐप द्वारा गणना किए गए बीएमआई को अलग-अलग दिखाया गया है ताकि उनके स्रोत स्पष्ट रहें।',
      'Reported and app-calculated BMI use different sources and are kept separate.':
          'रिपोर्ट किए गए और ऐप द्वारा गणना किए गए बीएमआई अलग-अलग स्रोतों से प्राप्त होते हैं और उन्हें अलग-अलग रखा जाता है।',
      'Reporting period': 'रिपोर्टिंग अवधि',
      'Reps': 'प्रतिनिधि',
      'Request a place': 'स्थान के लिए अनुरोध करें',
      'Request a review': 'समीक्षा का अनुरोध करें',
      'Request a review to begin a personalized program with clear actions and progress tracking.':
          'स्पष्ट कार्ययोजना और प्रगति ट्रैकिंग के साथ एक वैयक्तिकृत कार्यक्रम शुरू करने के लिए समीक्षा का अनुरोध करें।',
      'Request approved': 'अनुरोध स्वीकृत',
      'Request denied': 'अनुरोध अस्वीकार किया',
      'Request expired': 'अनुरोध की समय सीमा समाप्त हो गई है',
      'Required': 'आवश्यक',
      'Required for doctor clearance': 'डॉक्टर से मंजूरी के लिए आवश्यक',
      'Reset': 'रीसेट करें',
      'Reset App?': 'ऐप रीसेट करें?',
      'Reset Onboarding': 'ऑनबोर्डिंग रीसेट करें',
      'Reset Password': 'पासवर्ड रीसेट',
      'Reset token not found in response':
          'प्रतिक्रिया में रीसेट टोकन नहीं मिला',
      'Resistance bands': 'प्रतिरोध संघों',
      'Respiratory health and breathing': 'श्वसन स्वास्थ्य और सांस लेना',
      'Responsible Physician': 'जिम्मेदार चिकित्सक',
      'Rest day': 'विश्राम का दिन',
      'Rest day — recover well': 'आराम का दिन — अच्छी तरह से आराम करें',
      'Resting Heart': 'विश्राम हृदय',
      'Resting heart rate': 'विश्राम के समय हृदय गति',
      'Results calculating': 'परिणामों की गणना',
      'Retake': 'फिर से लेना',
      'Retake Photo': 'फोटो दोबारा लें',
      'Retry': 'पुन: प्रयास करें',
      'Retrying': 'पुनः प्रयास किया जाएगा',
      'Return to Arcare App and refresh':
          'आर्केयर ऐप पर वापस जाएं और रीफ़्रेश करें।',
      'Returning cached HealthData on general error.':
          'सामान्य त्रुटि होने पर कैश्ड हेल्थडेटा लौटाना।',
      'Returning cached daily records on full fetch error.':
          'पूर्ण फ़ेच त्रुटि होने पर कैश्ड दैनिक रिकॉर्ड लौटाए जा रहे हैं।',
      'Review': 'समीक्षा',
      'Review completed workouts and download PDFs':
          'पूरे किए गए वर्कआउट की समीक्षा करें और पीडीएफ डाउनलोड करें',
      'Review date will be confirmed on activation':
          'समीक्षा तिथि सक्रियण के समय पुष्टि की जाएगी',
      'Review due': 'समीक्षा देय',
      'Review in progress': 'समीक्षा जारी है',
      'Review program': 'समीक्षा कार्यक्रम',
      'Revoke': 'रद्द करना',
      'Revoke Explicit Consent': 'स्पष्ट सहमति रद्द करें',
      'Revoke Medical Consent?': 'चिकित्सीय सहमति रद्द करें?',
      'Rewards & Milestone Announcements': 'पुरस्कार और उपलब्धि संबंधी घोषणाएँ',
      'Rewards & Offers': 'पुरस्कार और ऑफ़र',
      'Rewards Points': 'रिवॉर्ड पॉइंट्स',
      'Rewind 10 seconds': '10 सेकंड पीछे जाएं',
      'Route in Google Maps': 'गूगल मैप्स में मार्ग',
      'S': 'एस',
      'SECURE HIPAA COMPLIANT PORTAL': 'सुरक्षित HIPAA अनुपालन पोर्टल',
      'SECURE, HIPAA COMPLIANT PORTAL': 'सुरक्षित, HIPAA के अनुरूप पोर्टल',
      'SESSION DURATION': 'सत्र की अवधि',
      'SLEEP': 'नींद',
      'SOS': 'मुसीबत का इशारा',
      'SOS Emergency': 'आपातकालीन सेवा संकेत',
      'SOS Triggered': 'एसओएस ट्रिगर हुआ',
      'SOS alert sent': 'SOS अलर्ट भेजा गया',
      'SSO log in': 'एसएसओ लॉगिन',
      'SSO sign up': 'एसएसओ साइन अप',
      'STEPS': 'चरण',
      'Sat': 'बैठा',
      'Saturday': 'शनिवार',
      'Save': 'बचाना',
      'Save Changes': 'परिवर्तनों को सुरक्षित करें',
      'Save at least two health reports to compare them.':
          'तुलना करने के लिए कम से कम दो स्वास्थ्य रिपोर्ट सुरक्षित रखें।',
      'Save changes': 'परिवर्तनों को सुरक्षित करें',
      'Save correction': 'सुधार सहेजें',
      'Save type': 'सहेजें प्रकार',
      'Save workout': 'वर्कआउट सेव करें',
      'Saving…': 'बचत हो रही है…',
      'Scan & start': 'स्कैन करें और शुरू करें',
      'Scan BMI report': 'स्कैन बीएमआई रिपोर्ट',
      'Scan Report': 'स्कैन रिपोर्ट',
      'Scan facility QR': 'स्कैन सुविधा क्यूआर',
      'Scan granted slot at the facility':
          'स्कैन के आधार पर सुविधा केंद्र में स्लॉट आवंटित किया गया',
      'Scan the facility QR to begin.':
          'शुरू करने के लिए सुविधा के क्यूआर कोड को स्कैन करें।',
      'Scan your gym BMI or body-composition report.':
          'अपने जिम बीएमआई या बॉडी-कंपोजिशन रिपोर्ट को स्कैन करें।',
      'Scheduled': 'अनुसूचित',
      'Score estimate': 'स्कोर अनुमान',
      'Screenshot import': 'स्क्रीनशॉट आयात करें',
      'Search Exercise Library': 'अभ्यास पुस्तकालय खोजें',
      'Search by exercise or topic': 'व्यायाम या विषय के आधार पर खोजें',
      'Sedentary': 'गतिहीन',
      'Select Gender': 'लिंग का चयन करें',
      'Select any conditions that apply to you. This helps us tailor your wellness insights.':
          'आप पर लागू होने वाली किसी भी स्थिति का चयन करें। इससे हमें आपकी सेहत से जुड़ी जानकारियों को बेहतर ढंग से समझने में मदद मिलेगी।',
      'Select the company that enrolled you and the facility you\'ll check in at.':
          'उस कंपनी का चयन करें जिसने आपका पंजीकरण कराया है और उस सुविधा केंद्र का चयन करें जहां आप चेक-इन करेंगे।',
      'Select your organization': 'अपना संगठन चुनें',
      'Selected training areas': 'चयनित प्रशिक्षण क्षेत्र',
      'Send Code': 'कोड भेजें',
      'Send OTP': 'ओटीपी भेजें',
      'Send SOS': 'SOS भेजें',
      'Sending request…': 'भेजने का अनुरोध…',
      'Sep': 'सितम्बर',
      'Session summary': 'सत्र का सारांश',
      'Set Wellness Goals 🎯': 'स्वास्थ्य संबंधी लक्ष्य निर्धारित करें 🎯',
      'Set a calorie target': 'कैलोरी का लक्ष्य निर्धारित करें',
      'Set personalized goals, monitor progress daily, and stay inspired to live a healthier life.':
          'व्यक्तिगत लक्ष्य निर्धारित करें, दैनिक आधार पर प्रगति की निगरानी करें और स्वस्थ जीवन जीने के लिए प्रेरित रहें।',
      'Sets': 'सेट',
      'Setup Google Fit synchronization':
          'Google Fit सिंक्रोनाइज़ेशन सेट अप करें',
      'Seven-day schedule': 'सात दिवसीय कार्यक्रम',
      'Severe or chronic allergic reactions':
          'गंभीर या दीर्घकालिक एलर्जी प्रतिक्रियाएं',
      'Shared with the wellness team': 'स्वास्थ्य टीम के साथ साझा किया गया',
      'Sharing is active. Qualifying facility managers can access your member-approved body-composition reports, saved comparisons, and workout results for their own facility only. Raw OCR transcripts, medical records, diagnoses, clinical notes, unrelated vitals, and workouts from other facilities are excluded.':
          'शेयरिंग सक्रिय है। योग्य सुविधा प्रबंधक केवल अपनी सुविधा के लिए आपके सदस्य-अनुमोदित बॉडी-कंपोज़िशन रिपोर्ट, सहेजे गए तुलनात्मक डेटा और वर्कआउट परिणामों तक पहुंच सकते हैं। अन्य सुविधाओं से प्राप्त रॉ ओसीआर ट्रांसक्रिप्ट, मेडिकल रिकॉर्ड, निदान, क्लिनिकल नोट्स, असंबंधित महत्वपूर्ण डेटा और वर्कआउट डेटा इसमें शामिल नहीं हैं।',
      'Sharing is not active. Booking and check-in cannot continue until you approve the facility workflow disclosure again.':
          'शेयरिंग सक्रिय नहीं है। जब तक आप सुविधा वर्कफ़्लो प्रकटीकरण को पुनः अनुमोदित नहीं करते, तब तक बुकिंग और चेक-इन जारी नहीं रह सकता।',
      'Short explanation': 'संक्षिप्त व्याख्या',
      'Shoulder': 'कंधा',
      'Shoulders': 'कंधों',
      'Shown separately from participation': 'भागीदारी से अलग दिखाया गया',
      'Sign In': 'दाखिल करना',
      'Sign In With a Code': 'कोड से साइन इन करें',
      'Sign Out': 'साइन आउट',
      'Sign Up': 'साइन अप करें',
      'Sign out': 'साइन आउट',
      'Sign out?': 'साइन आउट?',
      'Sign up with SSO': 'एसएसओ के साथ साइन अप करें',
      'Sign-in code sent to email': 'साइन-इन कोड ईमेल पर भेजा गया है',
      'Signing in securely...': 'सुरक्षित रूप से लॉग इन करें...',
      'Simulated Demo Active': 'सिम्युलेटेड डेमो सक्रिय',
      'Skeletal muscle': 'कंकाल की मांसपेशी',
      'Skip for now': 'अभी के लिए छोड़ दे',
      'Sleep': 'नींद',
      'Sleep & Body composition': 'नींद और शरीर की संरचना',
      'Sleep Duration': 'नींद की अवधि',
      'Sleep Duration Goal 🌙': 'नींद की अवधि का लक्ष्य 🌙',
      'Sleep Quality': 'नींद की गुणवत्ता',
      'Sleep Schedule': 'नींद का कार्यक्रम',
      'Sleep Schedule Alerts': 'नींद के समय से संबंधित अलर्ट',
      'Slot booked': 'स्लॉट बुक हो गया',
      'SocketException': 'सॉकेटएक्सेप्शन',
      'SpO2 Oxygen': 'SpO2 ऑक्सीजन',
      'Special Symbol': 'विशेष प्रतीक',
      'Specialist-approved member plan': 'विशेषज्ञ द्वारा अनुमोदित सदस्य योजना',
      'Staff and service': 'कर्मचारी और सेवा',
      'Start': 'शुरू',
      'Start with a care review': 'देखभाल समीक्षा से शुरुआत करें',
      'Start your journey to optimized wellness today.':
          'आज ही अपने स्वास्थ्य को परिपूर्ण बनाने की यात्रा शुरू करें।',
      'Starting soon': 'जल्द ही शुरू',
      'Starting today-only merge for daily health records to avoid rate limit':
          'आज से ही दैनिक स्वास्थ्य रिकॉर्डों के लिए मर्ज शुरू किया जा रहा है ताकि दर सीमा से बचा जा सके।',
      'Starts': 'प्रारंभ होगा',
      'Status': 'स्थिति',
      'Stay hydrated throughout the day':
          'दिनभर पर्याप्त मात्रा में पानी पीते रहें।',
      'Stay motivated with smart wellness alerts':
          'स्मार्ट वेलनेस अलर्ट के साथ प्रेरित रहें',
      'Stay tuned for new events.': 'नए आयोजनों के लिए जुड़े रहें।',
      'Steps': 'चरण',
      'Steps, water, sleep & calorie targets':
          'कदमों की संख्या, पानी, नींद और कैलोरी के लक्ष्य',
      'Still working out': 'अभी भी कसरत कर रहा हूँ',
      'Strength session @ Office Gym': 'ऑफिस जिम में स्ट्रेंथ ट्रेनिंग सेशन',
      'Stress Reduction': 'तनाव कम करना',
      'Stress level': 'तनाव स्तर',
      'Strong Password': 'मज़बूत पारण शब्द',
      'Subcutaneous fat': 'चमड़े के नीचे की वसा',
      'Submit Check-in': 'चेक-इन सबमिट करें',
      'Submit anonymously': 'अनाम रूप से सबमिट करें',
      'Submit feedback': 'प्रतिक्रिया भेजें',
      'Submit rating': 'रेटिंग सबमिट करें',
      'Submitted anonymously': 'गुमनाम रूप से प्रस्तुत किया गया',
      'Submitted — awaiting medical clearance review':
          'प्रस्तुत किया गया — चिकित्सा मंजूरी की समीक्षा का इंतजार है',
      'Success!': 'सफलता!',
      'Suggest a healthy snack': 'एक पौष्टिक नाश्ता सुझाएं',
      'Sun': 'सूरज',
      'Sunday': 'रविवार',
      'Sync & Refresh Dashboard': 'डैशबोर्ड को सिंक और रीफ़्रेश करें',
      'Sync Guide': 'सिंक गाइड',
      'Sync Health Records': 'स्वास्थ्य रिकॉर्ड को सिंक्रनाइज़ करें',
      'Sync Now': 'अभी सिंक करें',
      'Sync Your Health Data': 'अपने स्वास्थ्य डेटा को सिंक्रोनाइज़ करें',
      'Sync pending': 'सिंक्रोनाइज़ेशन लंबित है',
      'Sync your steps, sleep, and heart rate automatically.':
          'अपने कदमों, नींद और हृदय गति को स्वचालित रूप से सिंक्रनाइज़ करें।',
      'Synced device data and your corrections':
          'डिवाइस का डेटा और आपके द्वारा किए गए सुधार सिंक्रनाइज़ हो गए हैं।',
      'Synced securely with explicit consent':
          'स्पष्ट सहमति से सुरक्षित रूप से सिंक्रनाइज़ किया गया',
      'System': 'प्रणाली',
      'Systolic/Diastolic': 'सिस्टोलिक डायस्टोलिक',
      'T': 'टी',
      'TODAY': 'आज',
      'TODAY\'S PLAN': 'आज की योजना',
      'TODAY\'S PLANS': 'आज की योजनाएँ',
      'TRACKED': 'ट्रैक',
      'Tailored feedback on health improvements.':
          'स्वास्थ्य में सुधार पर अनुकूलित प्रतिक्रिया।',
      'Tap a target to locate it on the body map.':
          'शरीर के मानचित्र पर लक्ष्य का पता लगाने के लिए उस पर टैप करें।',
      'Tap anywhere to log water intake':
          'पानी के सेवन को रिकॉर्ड करने के लिए कहीं भी टैप करें।',
      'Tap to alert emergency contacts':
          'आपातकालीन संपर्कों को सूचित करने के लिए टैप करें',
      'Tap to view step-by-step sync setup':
          'सिंक सेटअप की चरण-दर-चरण प्रक्रिया देखने के लिए टैप करें',
      'Tdap (Tetanus, Diphtheria, Pertussis) Vaccine':
          'टीडीएपी (टेटनस, डिप्थीरिया, पर्टुसिस) वैक्सीन',
      'Tell Us About Yourself': 'अपने बारे में हमें बताएं',
      'Tell me a little more': 'मुझे थोड़ा और बताओ',
      'Tell us about your current lifestyle and what you\'re looking to achieve with Vitality.':
          'हमें अपनी वर्तमान जीवनशैली के बारे में बताएं और आप वाइटैलिटी के साथ क्या हासिल करना चाहते हैं।',
      'Tell us what worked well or could improve.':
          'हमें बताएं कि क्या अच्छा रहा या किसमें सुधार किया जा सकता है।',
      'Temporarily unavailable': 'अस्थाई रूप से अनुपलब्ध',
      'Terms of Service': 'सेवा की शर्तें',
      'Text is read securely on this device. You can edit every value before approving and saving it.':
          'इस डिवाइस पर टेक्स्ट को सुरक्षित रूप से पढ़ा जाता है। आप इसे स्वीकृत और सहेजने से पहले प्रत्येक मान को संपादित कर सकते हैं।',
      'Thanks for sharing how you\'re doing today.':
          'आज आप कैसे हैं, यह बताने के लिए धन्यवाद।',
      'Thanks — your facility feedback was submitted.':
          'धन्यवाद — आपकी सुविधा संबंधी प्रतिक्रिया भेज दी गई है।',
      'Thanks — your workout feedback was submitted.':
          'धन्यवाद — आपकी वर्कआउट संबंधी प्रतिक्रिया भेज दी गई है।',
      'That PDF has more than five pages. Use a shorter PDF or a screenshot of the report.':
          'उस पीडीएफ फाइल में पांच से अधिक पृष्ठ हैं। कृपया छोटी पीडीएफ फाइल या रिपोर्ट का स्क्रीनशॉट इस्तेमाल करें।',
      'That PDF is larger than 10 MB. Choose a shorter PDF or import a screenshot instead.':
          'वह पीडीएफ फाइल 10 एमबी से बड़ी है। कृपया कोई छोटी पीडीएफ फाइल चुनें या स्क्रीनशॉट आयात करें।',
      'The completion PDF could not be prepared.':
          'पूर्ण होने पर पीडीएफ फाइल तैयार नहीं की जा सकी।',
      'The facility manager declined this walk-in. Book the suggested empty slot or choose another nearby facility.':
          'सुविधा प्रबंधक ने बिना अपॉइंटमेंट के आने वाले इस ग्राहक को मना कर दिया। कृपया सुझाए गए खाली स्लॉट में बुकिंग करें या आस-पास की किसी अन्य सुविधा का चुनाव करें।',
      'The facility manager granted an extra place. Open the scanner when you arrive.':
          'सुविधा प्रबंधक ने एक अतिरिक्त स्थान उपलब्ध कराया है। पहुँचने पर स्कैनर खोल लें।',
      'The facility manager has up to 15 minutes to approve this request.':
          'सुविधा प्रबंधक के पास इस अनुरोध को स्वीकृत करने के लिए 15 मिनट तक का समय है।',
      'The granted place is not ready yet. Please refresh your bookings.':
          'आपको जो स्थान आवंटित किया गया है, वह अभी तैयार नहीं है। कृपया अपनी बुकिंग को फिर से अपडेट करें।',
      'The offer was declined.': 'प्रस्ताव को अस्वीकार कर दिया गया।',
      'The progress PDF could not be prepared.':
          'प्रगति संबंधी पीडीएफ तैयार नहीं की जा सकी।',
      'The selected PDF is empty or corrupt. Choose another report.':
          'चुनी गई पीडीएफ फाइल खाली है या दूषित है। कृपया कोई दूसरी रिपोर्ट चुनें।',
      'The source is not uploaded or retained. Review the extracted values before approving and saving this report.':
          'स्रोत अपलोड या सहेजा नहीं गया है। इस रिपोर्ट को स्वीकृत और सहेजने से पहले निकाले गए मानों की समीक्षा करें।',
      'The workout timer could not appear outside the app. Your workout remains active; retry while the app is open.':
          'वर्कआउट टाइमर ऐप के बाहर दिखाई नहीं दे रहा है। आपका वर्कआउट अभी भी सक्रिय है; ऐप खुला रहते हुए पुनः प्रयास करें।',
      'There are no measurements with values in both reports.':
          'दोनों रिपोर्टों में मूल्यों के साथ कोई माप नहीं हैं।',
      'These changes affect only your personal summary. They never change facility attendance, your approved plan, reports, rewards, challenges, or staff metrics.':
          'ये बदलाव केवल आपके व्यक्तिगत सारांश को प्रभावित करते हैं। इनसे सुविधा में उपस्थिति, आपकी स्वीकृत योजना, रिपोर्ट, पुरस्कार, चुनौतियाँ या कर्मचारी संबंधी मापदंड कभी नहीं बदलते।',
      'Thinking...': 'सोच...',
      'This QR belongs to another facility.':
          'यह क्यूआर किसी अन्य सुविधा से संबंधित है।',
      'This affects only your personal weekly summary; the official facility session stays unchanged.':
          'इससे केवल आपकी व्यक्तिगत साप्ताहिक सारांश रिपोर्ट प्रभावित होगी; आधिकारिक सुविधा सत्र अपरिवर्तित रहेगा।',
      'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for the member.':
          'यह तुलना केवल दर्ज किए गए परिवर्तनों का वर्णन करती है। यह इस बात का आकलन नहीं करती कि सदस्य के लिए क्या स्वस्थ है और क्या अस्वस्थ।',
      'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for you.':
          'यह तुलना केवल दर्ज किए गए परिवर्तनों का वर्णन करती है। यह इस बात का आकलन नहीं करती कि आपके लिए क्या स्वस्थ है और क्या अस्वस्थ।',
      'This facility request has expired.':
          'इस सुविधा के लिए किया गया अनुरोध समाप्त हो चुका है।',
      'This permanently deletes the report and any comparisons that use it.':
          'इससे रिपोर्ट और उससे संबंधित सभी तुलनाएं स्थायी रूप से हटा दी जाएंगी।',
      'This permanently deletes the saved comparison. Your health reports will not be deleted.':
          'इससे सहेजी गई तुलना स्थायी रूप से हट जाएगी। आपकी स्वास्थ्य रिपोर्ट नहीं हटेंगी।',
      'This replaces only your personal-summary entry. Official attendance remains unchanged.':
          'यह केवल आपकी व्यक्तिगत जानकारी को प्रतिस्थापित करेगा। आधिकारिक उपस्थिति में कोई बदलाव नहीं होगा।',
      'This report is too long to process. Use a shorter PDF or a clear screenshot of the report.':
          'यह रिपोर्ट प्रोसेस करने के लिए बहुत लंबी है। कृपया एक छोटी पीडीएफ फाइल या रिपोर्ट का स्पष्ट स्क्रीनशॉट भेजें।',
      'This report separates participation, elapsed time and recorded measurements. It does not make an automated claim of clinical improvement.':
          'यह रिपोर्ट सहभागिता, व्यतीत समय और दर्ज किए गए मापों को अलग-अलग दर्शाती है। यह नैदानिक ​​सुधार का स्वतः दावा नहीं करती है।',
      'This time overlaps another booking':
          'यह समय किसी अन्य बुकिंग के साथ मेल खाता है।',
      'This time overlaps another booking. Choose a different hour.':
          'यह समय किसी अन्य बुकिंग के साथ मेल खाता है। कृपया कोई दूसरा समय चुनें।',
      'This was updated elsewhere. Refresh and review the latest correction.':
          'इसे अन्यत्र अपडेट किया गया है। नवीनतम सुधार के लिए पेज को रिफ्रेश करके समीक्षा करें।',
      'This will clear all onboarding and local cache data, returning you to the onboarding wizard. Proceed?':
          'इससे ऑनबोर्डिंग और लोकल कैश का सारा डेटा साफ़ हो जाएगा और आप वापस ऑनबोर्डिंग विज़ार्ड पर पहुँच जाएँगे। आगे बढ़ें?',
      'Thu': 'गुरु',
      'Thursday': 'गुरुवार',
      'Tick assigned sets in order. The next set stays locked until the previous set is done':
          'निर्धारित सेटों पर क्रमानुसार निशान लगाएं। अगला सेट तब तक लॉक रहेगा जब तक पिछला सेट पूरा नहीं हो जाता।',
      'Tick each set in order. This exercise ticks itself when every set is done':
          'प्रत्येक सेट को क्रम से चिह्नित करें। सभी सेट पूरे होने पर यह अभ्यास स्वतः चिह्नित हो जाएगा।',
      'Tick sets in order. The next set stays locked until the previous set is done.':
          'क्रमानुसार टिक करें। पिछला सेट पूरा होने तक अगला सेट लॉक रहेगा।',
      'Tips for staying hydrated': 'हाइड्रेटेड रहने के लिए टिप्स',
      'Today': 'आज',
      'Today\'s actions': 'आज की कार्रवाई',
      'Today\'s checklist': 'आज की चेकलिस्ट',
      'Today\'s exercises work the upper body, core and lower body.':
          'आज के व्यायाम से शरीर के ऊपरी भाग, कोर और निचले भाग पर काम होता है।',
      'Today\'s muscle focus': 'आज का मुख्य फोकस मांसपेशियों पर है।',
      'Today\'s workout plan': 'आज की कसरत योजना',
      'Today’s calories and protein': 'आज की कैलोरी और प्रोटीन',
      'Today’s intake': 'आज का प्रवेश',
      'Today’s meals': 'आज का भोजन',
      'Tomorrow': 'कल',
      'Total Points': 'कुल अंक',
      'Track your daily health, activity, nutrition, and wellness records all in one place.':
          'अपने दैनिक स्वास्थ्य, गतिविधि, पोषण और तंदुरुस्ती से संबंधित सभी रिकॉर्ड एक ही स्थान पर ट्रैक करें।',
      'Tracked': 'ट्रैक',
      'Training type': 'प्रशिक्षण प्रकार',
      'Trains at': 'ट्रेनें',
      'Trends Graph': 'रुझान ग्राफ',
      'Triceps': 'त्रिशिस्क',
      'Trigger SOS?': 'SOS ट्रिगर करें?',
      'Try Again': 'पुनः प्रयास करें',
      'Try Demo Mode': 'डेमो मोड आज़माएँ',
      'Try again': 'पुनः प्रयास करें',
      'Tue': 'मंगल',
      'Tuesday': 'मंगलवार',
      'Turn flash off': 'फ़्लैश बंद करें',
      'Turn flash on': 'फ़्लैश चालू करें',
      'Two qualifying readings are needed': 'दो योग्यता संबंधी पठन आवश्यक हैं',
      'Type': 'प्रकार',
      'Type 1, Type 2, or Prediabetes': 'टाइप 1, टाइप 2 या प्रीडायबिटीज',
      'Type your full name as your electronic signature':
          'अपने इलेक्ट्रॉनिक हस्ताक्षर के रूप में अपना पूरा नाम टाइप करें',
      'U': 'यू',
      'Unable to book an available slot': 'उपलब्ध स्लॉट बुक करने में असमर्थ',
      'Unable to load notifications. Pull down to try again.':
          'नोटिफिकेशन लोड नहीं हो पा रहे हैं। कृपया नीचे की ओर खींचकर पुनः प्रयास करें।',
      'Unavailable': 'अनुपलब्ध',
      'Unavailable until two qualifying measurements are recorded':
          'दो निर्धारित माप दर्ज होने तक अनुपलब्ध',
      'Underweight': 'वजन',
      'Undo': 'पूर्ववत',
      'Unexpected add water log response format':
          'अप्रत्याशित जल लॉग प्रतिक्रिया प्रारूप जोड़ें',
      'Unexpected correction history response':
          'अप्रत्याशित सुधार इतिहास प्रतिक्रिया',
      'Unexpected mood check-in response format':
          'अप्रत्याशित मनोदशा जांच प्रतिक्रिया प्रारूप',
      'Unexpected notifications response format':
          'अप्रत्याशित सूचनाओं की प्रतिक्रिया प्रारूप',
      'Unexpected nutrition logs response format':
          'अप्रत्याशित पोषण लॉग प्रतिक्रिया प्रारूप',
      'Unexpected update water log response format':
          'अप्रत्याशित अद्यतन जल लॉग प्रतिक्रिया प्रारूप',
      'Unexpected water graph response format':
          'अप्रत्याशित जल ग्राफ प्रतिक्रिया प्रारूप',
      'Unexpected water logs response format':
          'अप्रत्याशित जल लॉग प्रतिक्रिया प्रारूप',
      'Unit': 'इकाई',
      'Unknown': 'अज्ञात',
      'Unknown error': 'अज्ञात त्रुटि',
      'Unlock points, tiers, and exclusive badges':
          'पॉइंट्स, टियर और एक्सक्लूसिव बैज अनलॉक करें',
      'Upcoming': 'आगामी',
      'Update Health': 'स्वास्थ्य अपडेट',
      'Update Your Health': 'अपने स्वास्थ्य को अपडेट करें',
      'Updating': 'अद्यतन करने',
      'Updating a nutrition log is not supported by the backend yet.':
          'पोषण लॉग को अपडेट करना अभी बैकएंड द्वारा समर्थित नहीं है।',
      'Updating estimate': 'अनुमान अपडेट किया जा रहा है',
      'Upper back': 'ऊपरी पीठ',
      'Uppercase Letter': 'बड़े अक्षर',
      'Use Photo': 'फ़ोटो का उपयोग करें',
      'Use code': 'कोड का उपयोग करें',
      'Use the QR displayed at the facility entrance to begin your workout.':
          'व्यायामशाला के प्रवेश द्वार पर प्रदर्शित क्यूआर कोड का उपयोग करके अपना व्यायाम सत्र शुरू करें।',
      'Use the camera to scan a gym report.':
          'जिम रिपोर्ट को स्कैन करने के लिए कैमरे का उपयोग करें।',
      'Use your camera to scan a gym BMI or body-composition report. The photo is read on this device and deleted before upload.':
          'अपने कैमरे का उपयोग करके जिम बीएमआई या बॉडी-कंपोज़िशन रिपोर्ट को स्कैन करें। फोटो को इस डिवाइस पर पढ़ा जाएगा और अपलोड करने से पहले डिलीट कर दिया जाएगा।',
      'Use your company work email. We will send a one-time code to finish.':
          'अपनी कंपनी के ईमेल पते का उपयोग करें। प्रक्रिया पूरी करने के लिए हम आपको एक बार उपयोग करने वाला कोड भेजेंगे।',
      'User': 'उपयोगकर्ता',
      'User email not available': 'उपयोगकर्ता का ईमेल उपलब्ध नहीं है',
      'User email not found. Please sign in again.':
          'उपयोगकर्ता का ईमेल पता नहीं चला। कृपया दोबारा लॉग इन करें।',
      'Vaccination': 'टीकाकरण',
      'Value': 'कीमत',
      'Vegan': 'शाकाहारी',
      'Vegetarian': 'शाकाहारी',
      'Verified progress': 'प्रगति सत्यापित हो गई',
      'Verified progress will appear after your activity syncs.':
          'आपकी गतिविधि सिंक होने के बाद सत्यापित प्रगति दिखाई देगी।',
      'Verified target reached': 'सत्यापित लक्ष्य प्राप्त हुआ',
      'Verify': 'सत्यापित करें',
      'Verify OTP': 'ओटीपी सत्यापित करें',
      'Very Active': 'बहुत सक्रिय',
      'Very low': 'बहुत कम',
      'Video is not available.': 'वीडियो उपलब्ध नहीं है।',
      'View All': 'सभी को देखें',
      'View Reports': 'रिपोर्ट देखें',
      'View completion summary': 'पूर्णता सारांश देखें',
      'View details': 'विवरण देखें',
      'View hourly slots': 'घंटेवार स्लॉट देखें',
      'View my program': 'मेरा प्रोग्राम देखें',
      'View other facilities': 'अन्य सुविधाएं देखें',
      'View pause details': 'विराम विवरण देखें',
      'View program': 'कार्यक्रम देखें',
      'View request status': 'अनुरोध की स्थिति देखें',
      'View status': 'स्थिति देखें',
      'View summary': 'सारांश देखें',
      'View today\'s meals': 'आज के भोजन देखें',
      'View today\'s session': 'आज का सत्र देखें',
      'View tomorrow\'s slots': 'कल के स्लॉट देखें',
      'Visceral fat': 'आंतरिक वसा',
      'Vitals & Heart': 'महत्वपूर्ण स्वास्थ्य और हृदय',
      'W': 'डब्ल्यू',
      'W28': 'डब्ल्यू28',
      'WATER ADD LOG': 'पानी डालें लॉग',
      'WATER DELETE LOG': 'जल विलोपन लॉग',
      'WATER GRAPH': 'जल ग्राफ',
      'WATER LOGS': 'जलभराव',
      'WATER UPDATE LOG': 'जल अद्यतन लॉग',
      'WEIGHT': 'वज़न',
      'WORK EMAIL': 'कार्य ईमेल',
      'WORKOUT': 'कसरत करना',
      'WORKOUT DURATION': 'व्यायाम की अवधि',
      'Walk for a few minutes or wait for the data to sync':
          'कुछ मिनट टहलें या डेटा सिंक होने का इंतजार करें।',
      'Water': 'पानी',
      'Water Hydration Goal 💧': 'शरीर में पानी की मात्रा बढ़ाने का लक्ष्य 💧',
      'Water Intake': 'पानी का सेवन',
      'Water Logs History': 'जल लॉग का इतिहास',
      'We could not connect to HealthKit. Please try again.':
          'हम HealthKit से कनेक्ट नहीं हो पाए। कृपया पुनः प्रयास करें।',
      'We could not find health measurements in that image. Try a sharper, well-lit photo of the complete report.':
          'हमें उस तस्वीर में स्वास्थ्य संबंधी माप नहीं मिले। कृपया पूरी रिपोर्ट की एक स्पष्ट और अच्छी रोशनी वाली तस्वीर भेजें।',
      'We could not find health measurements in that screenshot. Choose a clear image of the complete report.':
          'उस स्क्रीनशॉट में हमें स्वास्थ्य संबंधी माप नहीं मिले। कृपया पूरी रिपोर्ट की स्पष्ट छवि चुनें।',
      'We could not open that PDF. It may be encrypted, corrupt, or unsupported.':
          'हम उस पीडीएफ फाइल को खोल नहीं सके। यह एन्क्रिप्टेड, दूषित या असमर्थित हो सकती है।',
      'We could not open the camera.': 'हम कैमरा खोल नहीं सके।',
      'We could not open the camera. Please try again.':
          'हम कैमरा नहीं खोल पाए। कृपया पुनः प्रयास करें।',
      'We could not read any pages from that PDF. It may be encrypted or corrupt.':
          'हम उस पीडीएफ फाइल का कोई भी पृष्ठ नहीं पढ़ सके। यह एन्क्रिप्टेड या दूषित हो सकती है।',
      'We could not read that report. Make sure the text is sharp and well lit.':
          'हम वह रिपोर्ट पढ़ नहीं पाए। सुनिश्चित करें कि पाठ स्पष्ट और अच्छी तरह से प्रकाशित हो।',
      'We could not read the report': 'हम रिपोर्ट नहीं पढ़ सके',
      'We estimate nutrition from the food and portion you describe.':
          'हम आपके द्वारा बताए गए भोजन और उसकी मात्रा के आधार पर पोषण का अनुमान लगाते हैं।',
      'We process clinical records locally on your device. Access is disabled until you provide explicit authorization.':
          'हम आपके डिवाइस पर ही नैदानिक ​​रिकॉर्ड संसाधित करते हैं। जब तक आप स्पष्ट अनुमति नहीं देते, तब तक पहुंच अक्षम रहेगी।',
      'We use this data to calculate your personalized wellness scores and recovery goals.':
          'हम इस डेटा का उपयोग आपके व्यक्तिगत स्वास्थ्य स्कोर और रिकवरी लक्ष्यों की गणना करने के लिए करते हैं।',
      'We will notify you when a Physician has prepared an offer.':
          'जब कोई चिकित्सक प्रस्ताव तैयार कर लेगा, तो हम आपको सूचित कर देंगे।',
      'We\'ll email a one-time code — no password needed.':
          'हम आपको एक बार इस्तेमाल होने वाला कोड ईमेल करेंगे — पासवर्ड की आवश्यकता नहीं है।',
      'Weak Security': 'कमजोर सुरक्षा',
      'Wed': 'बुधवार',
      'Wednesday': 'बुधवार',
      'Week': 'सप्ताह',
      'Week-by-Week Logs (Last 4 Weeks)': 'सप्ताहवार लॉग (पिछले 4 सप्ताह)',
      'Weekly': 'साप्ताहिक',
      'Weekly Average': 'साप्ताहिक औसत',
      'Weekly Average Steps': 'साप्ताहिक औसत कदम',
      'Weekly Care Progress': 'साप्ताहिक देखभाल प्रगति',
      'Weekly Hydration Champion': 'साप्ताहिक हाइड्रेशन चैंपियन',
      'Weekly logs of total distance and calories.':
          'कुल तय की गई दूरी और कैलोरी का साप्ताहिक रिकॉर्ड।',
      'Weekly training': 'साप्ताहिक प्रशिक्षण',
      'Weekly training is unavailable. Your existing health data is still safe.':
          'साप्ताहिक प्रशिक्षण उपलब्ध नहीं है। आपका मौजूदा स्वास्थ्य डेटा सुरक्षित है।',
      'Weight': 'वज़न',
      'Weight (kg)': 'वजन (किलोग्राम)',
      'Weight Loss': 'वजन घटाना',
      'Welcome to Your Wellness Journey':
          'आपकी सेहत की यात्रा में आपका स्वागत है',
      'Wellness Goals': 'स्वास्थ्य लक्ष्य',
      'Wellness Score': 'स्वास्थ्य स्कोर',
      'Wellness Sync securely aggregates data from Google Health Connect & Apple HealthKit to populate your activity totals automatically.':
          'वेलनेस सिंक, गूगल हेल्थ कनेक्ट और एप्पल हेल्थकिट से डेटा को सुरक्षित रूप से एकत्रित करता है ताकि आपकी गतिविधि के कुल योग स्वचालित रूप से भर जाएं।',
      'Wellness data is synced automatically.':
          'स्वास्थ्य संबंधी डेटा स्वचालित रूप से सिंक्रनाइज़ हो जाता है।',
      'Where do you feel it?': 'आपको यह कहाँ महसूस होता है?',
      'Wiping medical consent will immediately remove all clinical records, vaccinations, and ECG reports from your view.':
          'मेडिकल सहमति को मिटाने से आपके सामने से सभी क्लिनिकल रिकॉर्ड, टीकाकरण और ईसीजी रिपोर्ट तुरंत हट जाएंगी।',
      'Withdraw': 'निकालना',
      'Withdraw access': 'पहुँच वापस लें',
      'Withdraw from this program': 'इस कार्यक्रम से अपना नाम वापस लें',
      'Withdraw from this program?': 'क्या आप इस कार्यक्रम से हटना चाहते हैं?',
      'Work email verification': 'कार्य ईमेल सत्यापन',
      'Work-email SSO accounts need Apple or Google signed in before Health data can be read from Apple Health or Health Connect.':
          'कार्य-ईमेल एसएसओ खातों को ऐप्पल हेल्थ या हेल्थ कनेक्ट से स्वास्थ्य डेटा पढ़ने से पहले ऐप्पल या गूगल में साइन इन करना आवश्यक है।',
      'Workout': 'कसरत करना',
      'Workout Plan': 'व्यायाम योजना',
      'Workout Reports': 'वर्कआउट रिपोर्ट',
      'Workout check-in code': 'वर्कआउट चेक-इन कोड',
      'Workout days this week': 'इस सप्ताह के वर्कआउट के दिन',
      'Workout in progress': 'व्यायाम जारी है',
      'Workout insights': 'व्यायाम संबंधी जानकारी',
      'Workout progress': 'व्यायाम की प्रगति',
      'Workout quality': 'व्यायाम की गुणवत्ता',
      'Workout report': 'व्यायाम रिपोर्ट',
      'Workout session completed.': 'वर्कआउट सेशन पूरा हुआ।',
      'Workout started. Your timer is running.':
          'व्यायाम शुरू हो गया है। आपका टाइमर चल रहा है।',
      'Workout timer unavailable': 'वर्कआउट टाइमर उपलब्ध नहीं है',
      'Worse': 'ज़्यादा बुरा',
      'Wrong workout type': 'गलत प्रकार की कसरत',
      'YOUR LAST 7 DAYS': 'आपके अंतिम 7 दिन',
      'Yes': 'हाँ',
      'Yes, open checkout': 'हां, चेकआउट खोलें',
      'Yesterday': 'कल',
      'Yoga': 'योग',
      'You are currently leading. The winner is decided after the timeline and sync grace period.':
          'आप फिलहाल आगे चल रहे हैं। विजेता का फैसला समय सीमा और सिंक के लिए निर्धारित समय सीमा समाप्त होने के बाद किया जाएगा।',
      'You are up to date for this week.':
          'आप इस सप्ताह की नवीनतम जानकारी से अवगत हैं।',
      'You can sign back in anytime with the same account.':
          'आप उसी खाते से कभी भी दोबारा लॉग इन कर सकते हैं।',
      'You have joined all challenges!': 'आपने सभी चुनौतियों में भाग लिया है!',
      'You have withdrawn from the program.':
          'आपने कार्यक्रम से अपना नाम वापस ले लिया है।',
      'You will be redirected to the Play Store to download the app.':
          'ऐप डाउनलोड करने के लिए आपको प्ले स्टोर पर रीडायरेक्ट कर दिया जाएगा।',
      'You will need to provide explicit consent again to re-sync them.':
          'उन्हें पुनः सिंक्रनाइज़ करने के लिए आपको फिर से स्पष्ट सहमति देनी होगी।',
      'Your AI Wellness Companion': 'आपका एआई वेलनेस साथी',
      'Your Activity Level': 'आपकी गतिविधि का स्तर',
      'Your Employer': 'आपका नियोक्ता',
      'Your Fitness Coach': 'आपका फिटनेस कोच',
      'Your Rewards': 'आपके पुरस्कार',
      'Your booked slot has ended': 'आपकी बुक की गई स्लॉट समाप्त हो गई है।',
      'Your care program is complete': 'आपका देखभाल कार्यक्रम पूरा हो गया है।',
      'Your care program is now active.':
          'आपका देखभाल कार्यक्रम अब सक्रिय हो गया है।',
      'Your care team': 'आपकी देखभाल टीम',
      'Your care team can recommend a program for you':
          'आपकी देखभाल टीम आपके लिए एक कार्यक्रम की सिफारिश कर सकती है।',
      'Your care team can recommend a program for your goals.':
          'आपकी देखभाल टीम आपके लक्ष्यों के लिए एक कार्यक्रम की सिफारिश कर सकती है।',
      'Your care team is reviewing the right program for you.':
          'आपकी देखभाल टीम आपके लिए उपयुक्त कार्यक्रम की समीक्षा कर रही है।',
      'Your care team is reviewing your request':
          'आपकी देखभाल टीम आपके अनुरोध की समीक्षा कर रही है।',
      'Your care team will retain the program history. You can request another review later.':
          'आपकी देखभाल टीम कार्यक्रम का पूरा इतिहास सुरक्षित रखेगी। आप बाद में समीक्षा का अनुरोध कर सकते हैं।',
      'Your checklist is saved. Your estimated workout insights are being updated.':
          'आपकी चेकलिस्ट सेव हो गई है। आपके अनुमानित वर्कआउट संबंधी जानकारी अपडेट की जा रही है।',
      'Your company specialist uses AI to prepare a plan from the health and preference information you provide. They review the plan before you can see it.':
          'आपकी कंपनी का विशेषज्ञ आपके द्वारा दी गई स्वास्थ्य और पसंद संबंधी जानकारी के आधार पर एक योजना तैयार करने के लिए कृत्रिम बुद्धिमत्ता (AI) का उपयोग करता है। योजना को देखने से पहले वे उसकी समीक्षा करते हैं।',
      'Your completion summary remains available here.':
          'आपकी पूर्णता सारांश रिपोर्ट यहां उपलब्ध है।',
      'Your correction changes this member-facing display and preserves the original synced reading.':
          'आपके द्वारा किए गए सुधार से सदस्यों के सामने प्रदर्शित होने वाला यह डिस्प्ले बदल जाता है और मूल सिंक्रनाइज़्ड रीडिंग सुरक्षित रहती है।',
      'Your current program continues until you accept this replacement offer.':
          'जब तक आप इस प्रतिस्थापन प्रस्ताव को स्वीकार नहीं कर लेते, तब तक आपका वर्तमान कार्यक्रम जारी रहेगा।',
      'Your enrolment needs a quick medical clearance review by our staff before your dashboard unlocks. We\'ll notify you once it\'s approved.':
          'आपके डैशबोर्ड को अनलॉक करने से पहले हमारे स्टाफ द्वारा आपके नामांकन की त्वरित चिकित्सा जांच की आवश्यकता है। मंजूरी मिलते ही हम आपको सूचित कर देंगे।',
      'Your estimated workout insights are being prepared. This page refreshes automatically.':
          'आपके अनुमानित वर्कआउट संबंधी जानकारी तैयार की जा रही है। यह पेज अपने आप रीफ़्रेश हो जाता है।',
      'Your first check-in will appear here.':
          'आपका पहला चेक-इन यहां दिखाई देगा।',
      'Your first completed visit helps your organisation understand the facility experience.':
          'आपकी पहली सफल यात्रा आपके संगठन को सुविधा के अनुभव को समझने में मदद करती है।',
      'Your first meal will appear here.': 'आपका पहला भोजन यहां दिखाई देगा।',
      'Your guidance and history remain available. New daily actions are paused.':
          'आपका मार्गदर्शन और इतिहास उपलब्ध रहेगा। दैनिक कार्यों की नई सूची रोक दी गई है।',
      'Your guidance and progress are saved. New actions are paused.':
          'आपके सुझाव और प्रगति सुरक्षित कर ली गई है। नए कार्य रोक दिए गए हैं।',
      'Your health identity & preferences':
          'आपकी स्वास्थ्य संबंधी पहचान और प्राथमिकताएँ',
      'Your health report': 'आपकी स्वास्थ्य रिपोर्ट',
      'Your iPhone does not support Live Activities. Your workout remains active and checkout is still available here.':
          'आपका iPhone लाइव एक्टिविटीज़ को सपोर्ट नहीं करता है। आपका वर्कआउट जारी रहेगा और आप यहां से चेकआउट कर सकते हैं।',
      'Your meal': 'आपका भोजन',
      'Your medical data is encrypted and only used to personalize your wellness experience. We never share your data with third parties.':
          'आपका मेडिकल डेटा एन्क्रिप्टेड है और इसका उपयोग केवल आपके स्वास्थ्य अनुभव को बेहतर बनाने के लिए किया जाता है। हम आपका डेटा कभी भी किसी तीसरे पक्ष के साथ साझा नहीं करते हैं।',
      'Your medical files, vaccinations, and lab results are protected under HIPAA/GDPR standards.':
          'आपकी मेडिकल फाइलें, टीकाकरण और प्रयोगशाला परिणाम HIPAA/GDPR मानकों के तहत सुरक्षित हैं।',
      'Your name is hidden from the wellness team; only trends are shared.':
          'आपका नाम वेलनेस टीम से छिपा हुआ है; केवल रुझान ही साझा किए जाते हैं।',
      'Your objectives': 'आपके उद्देश्य',
      'Your password has been successfully reset. You can now log in with your new credentials.':
          'आपका पासवर्ड सफलतापूर्वक रीसेट हो गया है। अब आप अपने नए क्रेडेंशियल्स से लॉग इन कर सकते हैं।',
      'Your personal check-in history is visible only in your account.':
          'आपकी व्यक्तिगत चेक-इन हिस्ट्री केवल आपके खाते में ही दिखाई देती है।',
      'Your phone is now at least 2 km from the exact place where you scanned into this workout. Open checkout to finish the active session.':
          'आपका फ़ोन अब उस स्थान से कम से कम 2 किलोमीटर दूर है जहाँ आपने इस वर्कआउट के लिए स्कैन किया था। एक्टिव सेशन पूरा करने के लिए चेकआउट खोलें।',
      'Your post-workout feedback': 'कसरत के बाद आपकी प्रतिक्रिया',
      'Your previous chats will appear here.':
          'आपकी पिछली चैट यहां दिखाई देंगी।',
      'Your recent visits help your organisation understand how this facility is performing.':
          'आपकी हालिया यात्राओं से आपके संगठन को यह समझने में मदद मिलती है कि यह सुविधा कैसा प्रदर्शन कर रही है।',
      'Your report is saved. Add your height in Profile to calculate app BMI.':
          'आपकी रिपोर्ट सेव हो गई है। ऐप द्वारा बीएमआई की गणना करने के लिए प्रोफ़ाइल में अपनी ऊंचाई दर्ज करें।',
      'Your saved care information is still safe.':
          'आपकी सहेजी गई देखभाल संबंधी जानकारी अभी भी सुरक्षित है।',
      'Your trend': 'आपका रुझान',
      'Your workout facts are safely saved. The AI estimate is temporarily unavailable.':
          'आपके वर्कआउट से संबंधित जानकारी सुरक्षित रूप से सहेज ली गई है। एआई अनुमान फिलहाल अनुपलब्ध है।',
      'Your workout facts are safely saved. We will retry the AI estimate automatically.':
          'आपके वर्कआउट से संबंधित जानकारी सुरक्षित रूप से सहेज ली गई है। हम स्वचालित रूप से एआई अनुमान को दोबारा आज़माएंगे।',
      'Your workout report is ready to review.':
          'आपकी वर्कआउट रिपोर्ट समीक्षा के लिए तैयार है।',
      'Zumba': 'ज़ुम्बा',
      'abdomen and midsection': 'पेट और मध्य भाग',
      'accept this suggested slot': 'इस सुझाए गए स्लॉट को स्वीकार करें',
      'activeCalories': 'सक्रिय कैलोरी',
      'alex@company.com': 'alex@company.com',
      'alex@vitality.pro': 'alex@vitality.pro',
      'alex@vitalitypro.com': 'alex@vitalitypro.com',
      'already have a booking': 'पहले से ही बुकिंग है',
      'already have the booking': 'बुकिंग पहले से ही हो चुकी है',
      'armScannerOrigin': 'आर्म स्कैनर उत्पत्ति',
      'back thighs': 'पीठ जांघें',
      'back upper arms': 'पीठ ऊपरी बाहें',
      'basal metabolic': 'बेसल मेटाबोलिक',
      'basalCalories': 'बेसल कैलोरी',
      'bloodGlucose': 'रक्त द्राक्ष - शर्करा',
      'bmrKcal': 'बीएमआरकेकेएल',
      'body age': 'शरीर की उम्र',
      'body fat': 'शरीर की चर्बी',
      'body mass index': 'बॉडी मास इंडेक्स',
      'body water': 'शरीर का पानी',
      'body weight': 'शरीर का वजन',
      'body-composition report': 'शरीर-संरचना रिपोर्ट',
      'bodyFat': 'शरीर की चर्बी',
      'bodyFatPct': 'शरीर में वसा प्रतिशत',
      'bodyWaterPct': 'शरीर का जल प्रतिशत',
      'bone mass': 'अस्थि द्रव्यमान',
      'bone weight': 'हड्डी का वजन',
      'boneMassKg': 'हड्डी का द्रव्यमान (किलोग्राम में)',
      'book this slot': 'इस स्लॉट को बुक करें',
      'bookingId': 'बुकिंग आईडी',
      'check in': 'चेक इन',
      'checkInAt': 'checkInAt',
      'checkoutRequested': 'चेकआउट का अनुरोध किया गया',
      'continueRequested': 'जारी रखें (अनुरोधित)',
      'current attendance session': 'वर्तमान उपस्थिति सत्र',
      'departureCheckoutRequired': 'प्रस्थान के लिए चेकआउट आवश्यक है',
      'diastolicBP': 'डायस्टोलिक बीपी',
      'dismissedSetupCard': 'खारिज किया गया सेटअपकार्ड',
      'e.g. Indian, Mediterranean': 'उदाहरण के लिए भारतीय, भूमध्यसागरीय',
      'e.g. peanuts': 'उदाहरण के लिए मूंगफली',
      'e.g., 3 bananas and 1 cup of yogurt':
          'उदाहरण के लिए, 3 केले और 1 कप दही',
      'employerAggregate': 'नियोक्ता कुल योग',
      'estimate pending': 'अनुमान लंबित है',
      'estimate updating': 'अनुमान अद्यतन',
      'exerciseMinutes': 'व्यायाम मिनट',
      'facilityName': 'सुविधा का नाम',
      'fat free': 'वसा रहित',
      'fat percentage': 'वसा प्रतिशत',
      'fatFreeBodyWeightKg': 'वसा रहित शरीर का वजन किलोग्राम',
      'front chest': 'सामने की छाती',
      'front thighs': 'सामने की जांघें',
      'front upper arms': 'सामने की ऊपरी भुजाएँ',
      'geofenceExited': 'जियोफेंस से बाहर निकल गया',
      'healthConnectRequested': 'स्वास्थ्य कनेक्शन अनुरोधित',
      'healthData': 'स्वास्थ्य डेटा',
      'healthSetupCompleted': 'स्वास्थ्य सेटअप पूर्ण हो गया',
      'heartRate': 'हृदय दर',
      'hideTimer': 'हाइडटाइमर',
      'hips and glutes': 'कूल्हे और नितंब',
      'inner thighs': 'अंदरूनी जांघे',
      'isTyping': 'टाइप कर रहा है',
      'isUser': 'उपयोगकर्ता',
      'lower arms': 'निचली भुजाएँ',
      'lower back': 'पीठ का निचला हिस्सा',
      'lower legs': 'निचले पैर',
      'market://details?id=com.google.android.apps.healthdata':
          'market://details?id=com.google.android.apps.healthdata',
      'mealAnalysis': 'भोजन विश्लेषण',
      'medicalRecords': 'मेडिकल रिकॉर्ड',
      'medicalRecordsConsented': 'चिकित्सा अभिलेखों के लिए सहमति दी गई',
      'medicalShare': 'मेडिकलशेयर',
      'metabolic age': 'चयापचय आयु',
      'metabolicAgeYears': 'चयापचय आयु वर्ष',
      'mg/dL': 'मिलीग्राम/डीएल',
      'mindfulnessMinutes': 'माइंडफुलनेस मिनट',
      'mmHg': 'mmHg',
      'muscle mass': 'मांसपेशियों',
      'muscle weight': 'मांसपेशियों का वजन',
      'muscleMassKg': 'मांसपेशी द्रव्यमान (किलोग्राम में)',
      'no data': 'कोई डेटा नहीं',
      'no workout completed': 'कोई व्यायाम पूरा नहीं हुआ',
      'non binary': 'गैर बाइनरी',
      'not recorded': 'रिकॉर्ड नहीं किया गया',
      'nutritionCalories': 'पोषण कैलोरी',
      'on track': 'ट्रैक पर',
      'optional integration not configured':
          'वैकल्पिक एकीकरण कॉन्फ़िगर नहीं किया गया है',
      'overlaps another booking': 'किसी अन्य बुकिंग के साथ ओवरलैप होता है',
      'pending review': 'समीक्षा लंबित है',
      'protein g': 'प्रोटीन ग्राम',
      'proteinPct': 'प्रोटीनपीसीटी',
      'radiusMeters': 'त्रिज्या मीटर',
      'reportedBmi': 'रिपोर्ट किया गया बीएमआई',
      'request a capacity override': 'क्षमता ओवरराइड का अनुरोध करें',
      'restingHeartRate': 'आराम करते समय हृदय गति',
      'sessionId': 'सत्र आईडी',
      'showPersistentTimer': 'शोपर्सिस्टेंटटाइमर',
      'showTimer': 'शोटाइमर',
      'sides of the back': 'पीठ के किनारे',
      'skeletal muscle': 'कंकाल की मांसपेशी',
      'skeletalMusclePct': 'कंकाल की मांसपेशी पीसीटी',
      'sleepDuration': 'नींद की अवधि',
      'sleepQuality': 'नींद की गुणवत्ता',
      'slotEndAt': 'स्लॉटएंडएट',
      'slotEndContinueRequested': 'स्लॉट समाप्त जारी रखने का अनुरोध किया गया',
      'start an instant check-in': 'तुरंत चेक-इन शुरू करें',
      'still working': 'अभी भी काम कर रहा है',
      'subcutaneous fat': 'चमड़े के नीचे की वसा',
      'subcutaneousFatPct': 'सबक्यूटेनियस फैटपीसीटी',
      'systolicBP': 'सिस्टोलिक बीपी',
      'the end of the plan period': 'योजना अवधि की समाप्ति',
      'this facility': 'यह सुविधा',
      'upload and get me the scored dashboard back':
          'स्कोरिंग डैशबोर्ड अपलोड करके मुझे वापस भेज दो।',
      'upper back': 'ऊपरी पीठ',
      'upper shoulders': 'ऊपरी कंधे',
      'visceral fat': 'आंतरिक वसा',
      'visceralFatLevel': 'आंतरिक वसा स्तर',
      'water percentage': 'पानी का प्रतिशत',
      'waterIntake': 'जल सेवन',
      'weightKg': 'वजन किलोग्राम',
      'your workout': 'आपका व्यायाम',
      '· Edited by member': '· सदस्य द्वारा संपादित',
      'हिन्दी (Hindi)': 'हिंदी (Hindi)',
      'ಕನ್ನಡ (Kannada)': 'कन्नड़ (Kannada)',
      '⚖️ Log Weight': '⚖️ लॉग का वजन',
      '🌙 Log Sleep': '🌙 लॉग स्लीप',
      '🌙 Sleep': '🌙 नींद',
      '🏆 You are the final winner. Your organization will contact you about the prize.':
          '🏆 आप अंतिम विजेता हैं। आपकी संस्था पुरस्कार के संबंध में आपसे संपर्क करेगी।',
      '💧 Hydration': '💧 जलयोजन',
      '💧 Log Water': '💧 लॉग वाटर',
      '🔥 Calories': '🔥 कैलोरी',
      '🚶 Log Steps': '🚶 कदमों की गिनती करें',
      '🚶 Steps': '🚶 सीढ़ियाँ',
    },
    'kn': {
      ').replaceAll(': ').ಎಲ್ಲವನ್ನೂ ಬದಲಾಯಿಸಿ(',
      ', member-entered': ', ಸದಸ್ಯ-ನಮೂದಿಸಲಾಗಿದೆ',
      '-W': '-ಡಬ್ಲ್ಯೂ',
      '0 ml': '0 ಮಿಲಿ',
      '0% relative change': '0% ಸಾಪೇಕ್ಷ ಬದಲಾವಣೆ',
      '0.0 hrs': '0.0 ಗಂಟೆಗಳು',
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz':
          '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz',
      '1 bowl dal': '1 ಬಟ್ಟಲು ದಾಲ್',
      '1 cup cooked rice': '1 ಕಪ್ ಬೇಯಿಸಿದ ಅನ್ನ',
      '1 medium banana': '1 ಮಧ್ಯಮ ಬಾಳೆಹಣ್ಣು',
      '1. Retrieve your clinical records, lab test reports, immunizations, and cardiology (ECG) data from your secure on-device health database.':
          '1. ನಿಮ್ಮ ಸುರಕ್ಷಿತ ಆನ್-ಡಿವೈಸ್ ಆರೋಗ್ಯ ಡೇಟಾಬೇಸ್‌ನಿಂದ ನಿಮ್ಮ ಕ್ಲಿನಿಕಲ್ ದಾಖಲೆಗಳು, ಲ್ಯಾಬ್ ಪರೀಕ್ಷಾ ವರದಿಗಳು, ರೋಗನಿರೋಧಕಗಳು ಮತ್ತು ಹೃದ್ರೋಗ (ECG) ಡೇಟಾವನ್ನು ಹಿಂಪಡೆಯಿರಿ.',
      '1000 ml': '1000 ಮಿ.ಲೀ.',
      '1500 ml': '1500 ಮಿ.ಲೀ.',
      '2 boiled eggs': '2 ಬೇಯಿಸಿದ ಮೊಟ್ಟೆಗಳು',
      '2. Process and cache this telemetry locally for offline visual dashboards. Your data will never be sent to any cloud backend or shared with third parties without your explicit intent.':
          '2. ಆಫ್‌ಲೈನ್ ದೃಶ್ಯ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗಳಿಗಾಗಿ ಈ ಟೆಲಿಮೆಟ್ರಿಯನ್ನು ಸ್ಥಳೀಯವಾಗಿ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಿ ಮತ್ತು ಕ್ಯಾಶ್ ಮಾಡಿ. ನಿಮ್ಮ ಸ್ಪಷ್ಟ ಉದ್ದೇಶವಿಲ್ಲದೆ ನಿಮ್ಮ ಡೇಟಾವನ್ನು ಯಾವುದೇ ಕ್ಲೌಡ್ ಬ್ಯಾಕೆಂಡ್‌ಗೆ ಕಳುಹಿಸಲಾಗುವುದಿಲ್ಲ ಅಥವಾ ಮೂರನೇ ವ್ಯಕ್ತಿಗಳೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಲಾಗುವುದಿಲ್ಲ.',
      '2000 ml': '2000 ಮಿ.ಲೀ.',
      '2026-W28': '2026-W28',
      '2500 ml': '2500 ಮಿ.ಲೀ.',
      '3 days left': '3 ದಿನಗಳು ಉಳಿದಿವೆ',
      '3. Understand that you can withdraw and revoke this consent at any time, which immediately deletes all local cache and locks medical records views.':
          '3. ನೀವು ಈ ಸಮ್ಮತಿಯನ್ನು ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ಹಿಂತೆಗೆದುಕೊಳ್ಳಬಹುದು ಮತ್ತು ಹಿಂತೆಗೆದುಕೊಳ್ಳಬಹುದು ಎಂಬುದನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಿ, ಇದು ಎಲ್ಲಾ ಸ್ಥಳೀಯ ಸಂಗ್ರಹವನ್ನು ತಕ್ಷಣವೇ ಅಳಿಸುತ್ತದೆ ಮತ್ತು ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳ ವೀಕ್ಷಣೆಗಳನ್ನು ಲಾಕ್ ಮಾಡುತ್ತದೆ.',
      '30 days': '30 ದಿನಗಳು',
      '5-min breath reset': '5-ನಿಮಿಷ ಉಸಿರಾಟದ ಮರುಹೊಂದಿಕೆ',
      '500 ml': '500 ಮಿ.ಲೀ.',
      '6-digit code': '6-ಅಂಕಿಯ ಕೋಡ್',
      '7 days': '7 ದಿನಗಳು',
      '8+ Characters': '8+ ಅಕ್ಷರಗಳು',
      ': (_error ??': ': (_ದೋಷ ??',
      'A balanced full-body session': 'ಸಮತೋಲಿತ ಪೂರ್ಣ-ದೇಹ ವ್ಯಾಯಾಮದ ಅವಧಿ',
      'A care program is ready': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ ಸಿದ್ಧವಾಗಿದೆ',
      'A change cannot be calculated until this measurement appears in both reports.':
          'ಈ ಅಳತೆಯು ಎರಡೂ ವರದಿಗಳಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುವವರೆಗೆ ಬದಲಾವಣೆಯನ್ನು ಲೆಕ್ಕಹಾಕಲಾಗುವುದಿಲ್ಲ.',
      'A fetchDailyHealthDataForPeriod request is already in progress. Coalescing request.':
          'fetchDailyHealthDataForPeriod ವಿನಂತಿಯು ಈಗಾಗಲೇ ಪ್ರಗತಿಯಲ್ಲಿದೆ. ವಿನಂತಿಯನ್ನು ಒಟ್ಟುಗೂಡಿಸಲಾಗುತ್ತಿದೆ.',
      'A fetchHealthData request is already in progress. Coalescing request.':
          'fetchHealthData ವಿನಂತಿಯು ಈಗಾಗಲೇ ಪ್ರಗತಿಯಲ್ಲಿದೆ. ವಿನಂತಿಯನ್ನು ಒಟ್ಟುಗೂಡಿಸಲಾಗುತ್ತಿದೆ.',
      'A quick, private check-in — takes 10 seconds.':
          'ತ್ವರಿತ, ಖಾಸಗಿ ಚೆಕ್-ಇನ್ — 10 ಸೆಕೆಂಡುಗಳು ತೆಗೆದುಕೊಳ್ಳುತ್ತದೆ.',
      'ACTIVE': 'ಸಕ್ರಿಯ',
      'ACTIVE GOAL HIT': 'ಸಕ್ರಿಯ ಗುರಿ ಹಿಟ್',
      'ACTIVE GOALS': 'ಸಕ್ರಿಯ ಗುರಿಗಳು',
      'ADD OTHER CONDITION': 'ಇತರ ಷರತ್ತು ಸೇರಿಸಿ',
      'ADDITIONAL MEASUREMENTS': 'ಹೆಚ್ಚುವರಿ ಅಳತೆಗಳು',
      'AGREE & ACTIVATE': 'ಒಪ್ಪಿ ಮತ್ತು ಸಕ್ರಿಯಗೊಳಿಸಿ',
      'AI ESTIMATE': 'AI ಅಂದಾಜು',
      'AI Wellness Buddy': 'AI ವೆಲ್ನೆಸ್ ಬಡ್ಡಿ',
      'AI Wellness Tips': 'AI ಸ್ವಾಸ್ಥ್ಯ ಸಲಹೆಗಳು',
      'AI features are not configured':
          'AI ವೈಶಿಷ್ಟ್ಯಗಳನ್ನು ಕಾನ್ಫಿಗರ್ ಮಾಡಲಾಗಿಲ್ಲ.',
      'AI is used to prepare a draft from the health and preference information you provide. Your company specialist reviews it before approval.':
          'ನೀವು ಒದಗಿಸುವ ಆರೋಗ್ಯ ಮತ್ತು ಆದ್ಯತೆಯ ಮಾಹಿತಿಯಿಂದ ಕರಡನ್ನು ತಯಾರಿಸಲು AI ಅನ್ನು ಬಳಸಲಾಗುತ್ತದೆ. ಅನುಮೋದನೆಯ ಮೊದಲು ನಿಮ್ಮ ಕಂಪನಿಯ ತಜ್ಞರು ಅದನ್ನು ಪರಿಶೀಲಿಸುತ್ತಾರೆ.',
      'AI meal estimate': 'AI ಊಟದ ಅಂದಾಜು',
      'AI plan for your week': 'ನಿಮ್ಮ ವಾರಕ್ಕೆ AI ಯೋಜನೆ',
      'AI tips': 'AI ಸಲಹೆಗಳು',
      'AM': 'ಬೆಳಗ್ಗೆ',
      'ANALYSIS LIVE': 'ವಿಶ್ಲೇಷಣೆ ಲೈವ್',
      'API_BASE_URL': 'ಎಪಿಐ_ಬೇಸ್_ಯುಆರ್ಎಲ್',
      'API_PATH_PREFIX': 'ಎಪಿಐ_ಪಾತ್_ಪ್ರೆಫಿಕ್ಸ್',
      'APP_BRAND': 'ಅಪ್ಲಿಕೇಶನ್_ಬ್ರ್ಯಾಂಡ್',
      'APP_BRAND must be medifit or mednovations':
          'APP_BRAND ವೈದ್ಯಕೀಯ ಅಥವಾ ವೈದ್ಯಕೀಯ ಆವಿಷ್ಕಾರಗಳಾಗಿರಬೇಕು.',
      'About the same': 'ಸುಮಾರು ಅದೇ',
      'Absent': 'ಅನುಪಸ್ಥಿತಿ',
      'Accept program': 'ಕಾರ್ಯಕ್ರಮವನ್ನು ಸ್ವೀಕರಿಸಿ',
      'Account Information': 'ಖಾತೆ ಮಾಹಿತಿ',
      'Action completed.': 'ಕ್ರಿಯೆ ಪೂರ್ಣಗೊಂಡಿದೆ.',
      'Action completion': 'ಕ್ರಿಯೆ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ',
      'Actions begin when the program is active.':
          'ಪ್ರೋಗ್ರಾಂ ಸಕ್ರಿಯವಾಗಿದ್ದಾಗ ಕ್ರಿಯೆಗಳು ಪ್ರಾರಂಭವಾಗುತ್ತವೆ.',
      'Active': 'ಸಕ್ರಿಯ',
      'Active 2-3 times a week, moderate daily movement.':
          'ವಾರಕ್ಕೆ 2-3 ಬಾರಿ ಸಕ್ರಿಯರಾಗಿರಿ, ದೈನಂದಿನ ಮಧ್ಯಮ ಚಲನೆ.',
      'Active Calories Target 🔥': 'ಸಕ್ರಿಯ ಕ್ಯಾಲೋರಿಗಳ ಗುರಿ 🔥',
      'Active Challenge': 'ಸಕ್ರಿಯ ಸವಾಲು',
      'Active Challenges': 'ಸಕ್ರಿಯ ಸವಾಲುಗಳು',
      'Active workout': 'ಸಕ್ರಿಯ ವ್ಯಾಯಾಮ',
      'Activity': 'ಚಟುವಟಿಕೆ',
      'Activity Alerts': 'ಚಟುವಟಿಕೆ ಎಚ್ಚರಿಕೆಗಳು',
      'Activity Prompts': 'ಚಟುವಟಿಕೆ ಪ್ರಾಂಪ್ಟ್‌ಗಳು',
      'Activity Summary': 'ಚಟುವಟಿಕೆ ಸಾರಾಂಶ',
      'Activity recognition permission was denied.':
          'ಚಟುವಟಿಕೆ ಗುರುತಿಸುವಿಕೆ ಅನುಮತಿಯನ್ನು ನಿರಾಕರಿಸಲಾಗಿದೆ.',
      'Add': 'ಸೇರಿಸಿ',
      'Add Contact': 'ಸಂಪರ್ಕವನ್ನು ಸೇರಿಸಿ',
      'Add Custom Condition': 'ಕಸ್ಟಮ್ ಸ್ಥಿತಿಯನ್ನು ಸೇರಿಸಿ',
      'Add Emergency Contact': 'ತುರ್ತು ಸಂಪರ್ಕವನ್ನು ಸೇರಿಸಿ',
      'Add a short explanation for Other.':
          '&#39;ಇತರೆ&#39; ಗಾಗಿ ಒಂದು ಸಣ್ಣ ವಿವರಣೆಯನ್ನು ಸೇರಿಸಿ.',
      'Add at least one health measurement before uploading.':
          'ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಕನಿಷ್ಠ ಒಂದು ಆರೋಗ್ಯ ಮಾಪನವನ್ನು ಸೇರಿಸಿ.',
      'Add contact': 'ಸಂಪರ್ಕವನ್ನು ಸೇರಿಸಿ',
      'Add custom exercise': 'ಕಸ್ಟಮ್ ವ್ಯಾಯಾಮ ಸೇರಿಸಿ',
      'Add extra exercise': 'ಹೆಚ್ಚುವರಿ ವ್ಯಾಯಾಮ ಸೇರಿಸಿ',
      'Add extra set': 'ಹೆಚ್ಚುವರಿ ಸೆಟ್ ಸೇರಿಸಿ',
      'Add measurement': 'ಅಳತೆಯನ್ನು ಸೇರಿಸಿ',
      'Add missing workout': 'ಕಾಣೆಯಾದ ವ್ಯಾಯಾಮವನ್ನು ಸೇರಿಸಿ',
      'Add people who should be notified when you trigger SOS.':
          'ನೀವು SOS ಅನ್ನು ಪ್ರಚೋದಿಸಿದಾಗ ತಿಳಿಸಬೇಕಾದ ಜನರನ್ನು ಸೇರಿಸಿ.',
      'Add to tracker': 'ಟ್ರ್ಯಾಕರ್‌ಗೆ ಸೇರಿಸಿ',
      'Adding…': 'ಸೇರಿಸಲಾಗುತ್ತಿದೆ...',
      'Advanced': 'ಸುಧಾರಿತ',
      'Aerobics': 'ಏರೋಬಿಕ್ಸ್',
      'Aggregate Reporting to Employer': 'ಉದ್ಯೋಗದಾತರಿಗೆ ಒಟ್ಟು ವರದಿ ಮಾಡುವಿಕೆ',
      'Agree & Authorize': 'ಒಪ್ಪುತ್ತೇನೆ ಮತ್ತು ದೃಢೀಕರಿಸುತ್ತೇನೆ',
      'Alert contacts': 'ಸಂಪರ್ಕಗಳನ್ನು ಎಚ್ಚರಿಸಿ',
      'Alex Rivers': 'ಅಲೆಕ್ಸ್ ರಿವರ್ಸ್',
      'All alerts off': 'ಎಲ್ಲಾ ಎಚ್ಚರಿಕೆಗಳು ಆಫ್ ಆಗಿವೆ',
      'All displayed slots are full': 'ಪ್ರದರ್ಶಿಸಲಾದ ಎಲ್ಲಾ ಸ್ಲಾಟ್‌ಗಳು ತುಂಬಿವೆ.',
      'All four consents below are required because a doctor must review your declared condition before clearance.':
          'ಕ್ಲಿಯರೆನ್ಸ್ ಮಾಡುವ ಮೊದಲು ವೈದ್ಯರು ನಿಮ್ಮ ಘೋಷಿತ ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಬೇಕಾಗಿರುವುದರಿಂದ ಕೆಳಗಿನ ನಾಲ್ಕು ಒಪ್ಪಿಗೆಗಳೂ ಅಗತ್ಯವಿದೆ.',
      'All major muscle groups': 'ಎಲ್ಲಾ ಪ್ರಮುಖ ಸ್ನಾಯು ಗುಂಪುಗಳು',
      'All sets done — exercise complete':
          'ಎಲ್ಲಾ ಸೆಟ್‌ಗಳು ಮುಗಿದಿವೆ — ವ್ಯಾಯಾಮ ಪೂರ್ಣಗೊಂಡಿದೆ',
      'All topics': 'ಎಲ್ಲಾ ವಿಷಯಗಳು',
      'Allergies': 'ಅಲರ್ಜಿಗಳು',
      'Allergies / avoid': 'ಅಲರ್ಜಿಗಳು / ತಪ್ಪಿಸಿ',
      'Allow & Finish': 'ಅನುಮತಿಸಿ ಮತ್ತು ಮುಗಿಸಿ',
      'Allow Camera': 'ಕ್ಯಾಮೆರಾ ಅನುಮತಿಸಿ',
      'Allow sync permissions to enable tracking.':
          'ಟ್ರ್ಯಾಕಿಂಗ್ ಸಕ್ರಿಯಗೊಳಿಸಲು ಸಿಂಕ್ ಅನುಮತಿಗಳನ್ನು ಅನುಮತಿಸಿ.',
      'Almost Synced!': 'ಬಹುತೇಕ ಸಿಂಕ್ ಆಗಿದೆ!',
      'Already have an account?': 'ಈಗಾಗಲೇ ಖಾತೆ ಇದೆಯೇ?',
      'Ambulance': 'ಆಂಬ್ಯುಲೆನ್ಸ್',
      'Amenities and comfort': 'ಸೌಕರ್ಯಗಳು ಮತ್ತು ಸೌಕರ್ಯಗಳು',
      'An unknown server error occurred.': 'ಅಜ್ಞಾತ ಸರ್ವರ್ ದೋಷ ಸಂಭವಿಸಿದೆ.',
      'Analyzing lifestyle metrics and wellness goals...':
          'ಜೀವನಶೈಲಿ ಮಾಪನಗಳು ಮತ್ತು ಸ್ವಾಸ್ಥ್ಯ ಗುರಿಗಳನ್ನು ವಿಶ್ಲೇಷಿಸುವುದು...',
      'Analyzing your activity and sleep logs... Syncing with advisor models...':
          'ನಿಮ್ಮ ಚಟುವಟಿಕೆ ಮತ್ತು ನಿದ್ರೆಯ ದಾಖಲೆಗಳನ್ನು ವಿಶ್ಲೇಷಿಸಲಾಗುತ್ತಿದೆ... ಸಲಹೆಗಾರ ಮಾದರಿಗಳೊಂದಿಗೆ ಸಿಂಕ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'Ankle/foot': 'ಕಣಕಾಲು/ಪಾದ',
      'Answer each question and select at least one pain area if you report pain.':
          'ಪ್ರತಿ ಪ್ರಶ್ನೆಗೆ ಉತ್ತರಿಸಿ ಮತ್ತು ನೀವು ನೋವನ್ನು ವರದಿ ಮಾಡಿದರೆ ಕನಿಷ್ಠ ಒಂದು ನೋವಿನ ಪ್ರದೇಶವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Any cardiovascular health concerns':
          'ಯಾವುದೇ ಹೃದಯರಕ್ತನಾಳದ ಆರೋಗ್ಯ ಕಾಳಜಿಗಳು',
      'Anything else? (optional)': 'ಇನ್ನೇನಾದರೂ? (ಐಚ್ಛಿಕ)',
      'App BMI': 'ಅಪ್ಲಿಕೇಶನ್ BMI',
      'App resumed: fetching fresh dashboard metrics':
          'ಅಪ್ಲಿಕೇಶನ್ ಪುನರಾರಂಭಿಸಲಾಗಿದೆ: ಹೊಸ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಮೆಟ್ರಿಕ್‌ಗಳನ್ನು ಪಡೆಯಲಾಗುತ್ತಿದೆ',
      'App-calculated BMI': 'ಅಪ್ಲಿಕೇಶನ್-ಲೆಕ್ಕಾಚಾರದ BMI',
      'Appearance': 'ಗೋಚರತೆ',
      'Apple': 'ಆಪಲ್',
      'Apple HealthKit': 'ಆಪಲ್ ಹೆಲ್ತ್‌ಕಿಟ್',
      'Apple Sign In is not available here. On the simulator, open Settings and sign in with an Apple ID, enable Sign in with Apple for this App ID in Apple Developer, then do a full rebuild.':
          'ಆಪಲ್ ಸೈನ್ ಇನ್ ಇಲ್ಲಿ ಲಭ್ಯವಿಲ್ಲ. ಸಿಮ್ಯುಲೇಟರ್‌ನಲ್ಲಿ, ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ ಮತ್ತು ಆಪಲ್ ಐಡಿಯೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ, ಆಪಲ್ ಡೆವಲಪರ್‌ನಲ್ಲಿ ಈ ಅಪ್ಲಿಕೇಶನ್ ಐಡಿಗಾಗಿ ಸೈನ್ ಇನ್ ವಿತ್ ಆಪಲ್ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ, ನಂತರ ಪೂರ್ಣ ಪುನರ್ರಚನೆಯನ್ನು ಮಾಡಿ.',
      'Apple Watch': 'ಆಪಲ್ ವಾಚ್',
      'Apple Watch Vitals': 'ಆಪಲ್ ವಾಚ್ ವೈಟಲ್ಸ್',
      'Approve': 'ಅನುಮೋದಿಸಿ',
      'Approve & Save': 'ಅನುಮೋದಿಸಿ ಮತ್ತು ಉಳಿಸಿ',
      'Approved': 'ಅನುಮೋದಿಸಲಾಗಿದೆ',
      'Apr': 'ಏಪ್ರಿಲ್',
      'Asia/Kolkata': 'ಏಷ್ಯಾ/ಕೋಲ್ಕತ್ತಾ',
      'Ask your coach about your next workout…':
          'ನಿಮ್ಮ ಮುಂದಿನ ವ್ಯಾಯಾಮದ ಬಗ್ಗೆ ನಿಮ್ಮ ತರಬೇತುದಾರರನ್ನು ಕೇಳಿ...',
      'Assigned workout': 'ನಿಯೋಜಿಸಲಾದ ವ್ಯಾಯಾಮ',
      'Asthma': 'ಆಸ್ತಮಾ',
      'At a glance': 'ಒಂದು ನೋಟದಲ್ಲಿ',
      'Attended': 'ಭಾಗವಹಿಸಿದ್ದಾರೆ',
      'Aug': 'ಆಗಸ್ಟ್',
      'Authorization': 'ಅಧಿಕಾರ',
      'Average pulse': 'ಸರಾಸರಿ ನಾಡಿಮಿಡಿತ',
      'BELOW TARGET': 'ಗುರಿ ಕೆಳಗೆ',
      'BLR1': 'ಬಿಎಲ್‌ಆರ್1',
      'BMI': 'ಬಿಎಂಐ',
      'BMI context': 'BMI ಸಂದರ್ಭ',
      'BMI type': 'ಬಿಎಂಐ ಪ್ರಕಾರ',
      'BMR': 'ಬಿಎಂಆರ್',
      'BODY COMPOSITION': 'ದೇಹದ ಸಂಯೋಜನೆ',
      'Back': 'ಹಿಂದೆ',
      'Back to Personal Info': 'ವೈಯಕ್ತಿಕ ಮಾಹಿತಿಗೆ ಹಿಂತಿರುಗಿ',
      'Back to sign in': 'ಸೈನ್ ಇನ್‌ಗೆ ಹಿಂತಿರುಗಿ',
      'Barbell': 'ಬಾರ್ಬೆಲ್',
      'Basic Profile': 'ಮೂಲ ಪ್ರೊಫೈಲ್',
      'Beginner': 'ಹರಿಕಾರ',
      'Begins when you accept': 'ನೀವು ಸ್ವೀಕರಿಸಿದಾಗ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ',
      'Better': 'ಉತ್ತಮ',
      'Better Sleep': 'ಉತ್ತಮ ನಿದ್ರೆ',
      'Biceps': 'ಬೈಸೆಪ್ಸ್',
      'Blood Pressure': 'ರಕ್ತದೊತ್ತಡ',
      'Blood Saturation': 'ರಕ್ತ ಶುದ್ಧತ್ವ',
      'Blood Sugar': 'ರಕ್ತದಲ್ಲಿನ ಸಕ್ಕರೆ',
      'Body Fat': 'ದೇಹದ ಕೊಬ್ಬು',
      'Body Mass Index': 'ದೇಹದ ದ್ರವ್ಯರಾಶಿ ಸೂಚ್ಯಂಕ',
      'Body Weight': 'ದೇಹದ ತೂಕ',
      'Body fat': 'ದೇಹದ ಕೊಬ್ಬು',
      'Body water': 'ದೇಹದ ನೀರು',
      'Bodyweight only': 'ದೇಹದ ತೂಕ ಮಾತ್ರ',
      'Bone mass': 'ಮೂಳೆ ದ್ರವ್ಯರಾಶಿ',
      'Book a Slot': 'ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಿ',
      'Book a facility activity': 'ಸೌಲಭ್ಯ ಚಟುವಟಿಕೆಯನ್ನು ಬುಕ್ ಮಾಡಿ',
      'Book suggested slot': 'ಪುಸ್ತಕ ಸೂಚಿಸಲಾದ ಸ್ಲಾಟ್',
      'Booked slot': 'ಬುಕ್ ಮಾಡಿದ ಸ್ಲಾಟ್',
      'Booking and check-in cannot continue because the facility workflow requires workout-data access.':
          'ಸೌಲಭ್ಯದ ಕಾರ್ಯಪ್ರವಾಹಕ್ಕೆ ವ್ಯಾಯಾಮ-ಡೇಟಾ ಪ್ರವೇಶದ ಅಗತ್ಯವಿರುವುದರಿಂದ ಬುಕಿಂಗ್ ಮತ್ತು ಚೆಕ್-ಇನ್ ಅನ್ನು ಮುಂದುವರಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.',
      'Bookings for today have closed at 10:00 PM. Choose tomorrow to reserve a slot.':
          'ಇಂದಿನ ಬುಕಿಂಗ್‌ಗಳು ರಾತ್ರಿ 10:00 ಗಂಟೆಗೆ ಮುಕ್ತಾಯಗೊಂಡಿವೆ. ಸ್ಲಾಟ್ ಕಾಯ್ದಿರಿಸಲು ನಾಳೆ ಆಯ್ಕೆಮಾಡಿ.',
      'Bottle': 'ಬಾಟಲ್',
      'Breathing time': 'ಉಸಿರಾಟದ ಸಮಯ',
      'Bright, airy interface': 'ಪ್ರಕಾಶಮಾನವಾದ, ಗಾಳಿಯಾಡುವ ಇಂಟರ್ಫೇಸ್',
      'Bronze Tier': 'ಕಂಚಿನ ಶ್ರೇಣಿ',
      'Build Healthy Habits': 'ಆರೋಗ್ಯಕರ ಅಭ್ಯಾಸಗಳನ್ನು ಬೆಳೆಸಿಕೊಳ್ಳಿ',
      'Build meal plan': 'ಊಟದ ಯೋಜನೆಯನ್ನು ನಿರ್ಮಿಸಿ',
      'Build muscle': 'ಸ್ನಾಯುಗಳನ್ನು ನಿರ್ಮಿಸಿ',
      'Build workout': 'ವ್ಯಾಯಾಮವನ್ನು ನಿರ್ಮಿಸಿ',
      'By continuing, you agree to our': 'ಮುಂದುವರಿಯುವ ಮೂಲಕ, ನೀವು ನಮ್ಮ',
      'By enabling Medical & Health Records synchronization, you explicitly consent and authorize the application to:':
          'ವೈದ್ಯಕೀಯ ಮತ್ತು ಆರೋಗ್ಯ ದಾಖಲೆಗಳ ಸಿಂಕ್ರೊನೈಸೇಶನ್ ಅನ್ನು ಸಕ್ರಿಯಗೊಳಿಸುವ ಮೂಲಕ, ನೀವು ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಸ್ಪಷ್ಟವಾಗಿ ಸಮ್ಮತಿಸುತ್ತೀರಿ ಮತ್ತು ಅಧಿಕಾರ ನೀಡುತ್ತೀರಿ:',
      'CARE': 'ಕಾಳಜಿ',
      'CHALLENGES OVERVIEW': 'ಸವಾಲುಗಳ ಅವಲೋಕನ',
      'CM': 'ಸಿಎಂ',
      'COMPLETED WORKOUT': 'ಪೂರ್ಣಗೊಂಡ ವ್ಯಾಯಾಮ',
      'CONTINUE': 'ಮುಂದುವರಿಸಿ',
      'COVID-19 Vaccination': 'COVID-19 ಲಸಿಕೆ',
      'CREATE': 'ರಚಿಸಿ',
      'Calculated avg.': 'ಲೆಕ್ಕಹಾಕಿದ ಸರಾಸರಿ.',
      'Call': 'ಕರೆ ಮಾಡಿ',
      'Calories': 'ಕ್ಯಾಲೋರಿಗಳು',
      'Calories & Exercise time': 'ಕ್ಯಾಲೋರಿಗಳು ಮತ್ತು ವ್ಯಾಯಾಮ ಸಮಯ',
      'Calories Burned': 'ಬರ್ನ್ ಮಾಡಿದ ಕ್ಯಾಲೊರಿಗಳು',
      'Calories today': 'ಇಂದಿನ ಕ್ಯಾಲೋರಿಗಳು',
      'Calves': 'ಕರುಗಳು',
      'Camera access is needed': 'ಕ್ಯಾಮರಾ ಪ್ರವೇಶ ಅಗತ್ಯವಿದೆ',
      'Camera access is required to scan a body-composition report.':
          'ದೇಹ-ಸಂಯೋಜನೆ ವರದಿಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಯಾಮರಾ ಪ್ರವೇಶದ ಅಗತ್ಯವಿದೆ.',
      'Camera access is required to scan the facility QR.':
          'ಸೌಲಭ್ಯದ QR ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಯಾಮೆರಾ ಪ್ರವೇಶದ ಅಗತ್ಯವಿದೆ.',
      'Camera access is required to scan the facility QR. Enable it in Settings.':
          'ಸೌಲಭ್ಯದ QR ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಯಾಮರಾ ಪ್ರವೇಶದ ಅಗತ್ಯವಿದೆ. ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅದನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ.',
      'Camera permission required': 'ಕ್ಯಾಮರಾ ಅನುಮತಿ ಅಗತ್ಯವಿದೆ',
      'Camera scan': 'ಕ್ಯಾಮೆರಾ ಸ್ಕ್ಯಾನ್',
      'Camera unavailable': 'ಕ್ಯಾಮೆರಾ ಲಭ್ಯವಿಲ್ಲ',
      'Cancel': 'ರದ್ದುಮಾಡಿ',
      'Can’t scan the sticker? Enter the facility code.':
          'ಸ್ಟಿಕ್ಕರ್ ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲವೇ? ಸೌಲಭ್ಯ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.',
      'Capture BMI report': 'BMI ವರದಿಯನ್ನು ಸೆರೆಹಿಡಿಯಿರಿ',
      'Carbs': 'ಕಾರ್ಬೋಹೈಡ್ರೇಟ್‌ಗಳು',
      'Cardiology': 'ಹೃದಯಶಾಸ್ತ್ರ',
      'Care Programs': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮಗಳು',
      'Care Programs could not be loaded.':
          'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Care Programs request failed': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮಗಳ ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ.',
      'Care Team': 'ಆರೈಕೆ ತಂಡ',
      'Care actions completed': 'ಆರೈಕೆ ಕ್ರಮಗಳು ಪೂರ್ಣಗೊಂಡಿವೆ',
      'Care program': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ',
      'Care program completed': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ ಪೂರ್ಣಗೊಂಡಿದೆ',
      'Care program paused': 'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮವನ್ನು ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ',
      'Care progress is unavailable': 'ಆರೈಕೆಯ ಪ್ರಗತಿ ಲಭ್ಯವಿಲ್ಲ.',
      'Care team professional': 'ಆರೈಕೆ ತಂಡದ ವೃತ್ತಿಪರ',
      'Challenge & Updates': 'ಸವಾಲು ಮತ್ತು ನವೀಕರಣಗಳು',
      'Challenge Updates': 'ಸವಾಲಿನ ನವೀಕರಣಗಳು',
      'Challenge ended — calculating verified results during the sync grace period.':
          'ಸವಾಲು ಕೊನೆಗೊಂಡಿದೆ — ಸಿಂಕ್ ಗ್ರೇಸ್ ಅವಧಿಯಲ್ಲಿ ಪರಿಶೀಲಿಸಿದ ಫಲಿತಾಂಶಗಳನ್ನು ಲೆಕ್ಕಾಚಾರ ಮಾಡುವುದು.',
      'Challenge ended — results are calculating.':
          'ಸವಾಲು ಮುಗಿದಿದೆ - ಫಲಿತಾಂಶಗಳು ಲೆಕ್ಕಾಚಾರ ಮಾಡುತ್ತಿವೆ.',
      'Challenges': 'ಸವಾಲುಗಳು',
      'Challenges 🏆': 'ಸವಾಲುಗಳು 🏆',
      'Change from earlier': 'ಮೊದಲಿನಿಂದ ಬದಲಾವಣೆ',
      'Change session type': 'ಅಧಿವೇಶನ ಪ್ರಕಾರವನ್ನು ಬದಲಾಯಿಸಿ',
      'Change type': 'ಪ್ರಕಾರವನ್ನು ಬದಲಾಯಿಸಿ',
      'Chat deleted.': 'ಚಾಟ್ ಅಳಿಸಲಾಗಿದೆ.',
      'Chat history': 'ಚಾಟ್ ಇತಿಹಾಸ',
      'Check in': 'ಚೆಕ್ ಇನ್ ಮಾಡಿ',
      'Check in now': 'ಈಗಲೇ ಚೆಕ್ ಇನ್ ಮಾಡಿ',
      'Check in now. Your facility manager will be notified.':
          'ಈಗಲೇ ಚೆಕ್ ಇನ್ ಮಾಡಿ. ನಿಮ್ಮ ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರಿಗೆ ಸೂಚಿಸಲಾಗುತ್ತದೆ.',
      'Check in now; your facility manager is notified':
          'ಈಗಲೇ ಚೆಕ್ ಇನ್ ಮಾಡಿ; ನಿಮ್ಮ ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರಿಗೆ ಸೂಚನೆ ನೀಡಲಾಗಿದೆ.',
      'Check out': 'ಪರಿಶೀಲಿಸಿ',
      'Check out now, or keep working. Keeping the session open will notify the facility manager.':
          'ಈಗಲೇ ಪರಿಶೀಲಿಸಿ, ಅಥವಾ ಕೆಲಸ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಿ. ಅಧಿವೇಶನವನ್ನು ತೆರೆದಿಟ್ಟರೆ ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರಿಗೆ ಸೂಚಿಸಲಾಗುತ್ತದೆ.',
      'Check status': 'ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಿ',
      'Check that every number is readable.':
          'ಪ್ರತಿಯೊಂದು ಸಂಖ್ಯೆಯನ್ನು ಓದಬಹುದಾಗಿದೆಯೇ ಎಂದು ಪರಿಶೀಲಿಸಿ.',
      'Check your connection and try again.':
          'ನಿಮ್ಮ ಸಂಪರ್ಕವನ್ನು ಪರಿಶೀಲಿಸಿ ಹಾಗೂ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Check-in logged': 'ಚೆಕ್-ಇನ್ ಲಾಗಿನ್ ಆಗಿದೆ',
      'Checklist completion': 'ಪರಿಶೀಲನಾಪಟ್ಟಿ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ',
      'Checkout': 'ಚೆಕ್ಔಟ್',
      'Chest': 'ಎದೆ',
      'Choose Gym, Yoga, Zumba, or another hourly activity, then reserve a slot or check in when you arrive.':
          'ಜಿಮ್, ಯೋಗ, ಜುಂಬಾ ಅಥವಾ ಇನ್ನೊಂದು ಗಂಟೆಯ ಚಟುವಟಿಕೆಯನ್ನು ಆರಿಸಿ, ನಂತರ ಸ್ಲಾಟ್ ಕಾಯ್ದಿರಿಸಿ ಅಥವಾ ನೀವು ಬಂದಾಗ ಚೆಕ್ ಇನ್ ಮಾಡಿ.',
      'Choose a WhatsApp or gallery screenshot.':
          'WhatsApp ಅಥವಾ ಗ್ಯಾಲರಿಯ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಆಯ್ಕೆಮಾಡಿ.',
      'Choose any two distinct saved reports. Reports from the same date are allowed.':
          'ಯಾವುದೇ ಎರಡು ವಿಭಿನ್ನ ಉಳಿಸಿದ ವರದಿಗಳನ್ನು ಆರಿಸಿ. ಒಂದೇ ದಿನಾಂಕದ ವರದಿಗಳನ್ನು ಅನುಮತಿಸಲಾಗಿದೆ.',
      'Choose how you want to add a body-composition report.':
          'ನೀವು ಮುಖ್ಯ-ಸಂಯೋಜನೆ ವರದಿಯನ್ನು ಹೇಗೆ ಸೇರಿಸಲು ಬಯಸುತ್ತೀರಿ ಎಂಬುದನ್ನು ಆರಿಸಿ.',
      'Choose language': 'ಭಾಷೆಯನ್ನು ಆರಿಸಿ',
      'Choose your organization': 'ನಿಮ್ಮ ಸಂಸ್ಥೆಯನ್ನು ಆರಿಸಿ',
      'City Health Clinic': 'ನಗರ ಆರೋಗ್ಯ ಚಿಕಿತ್ಸಾಲಯ',
      'City Hospital': 'ನಗರ ಆಸ್ಪತ್ರೆ',
      'Cleanliness': 'ಸ್ವಚ್ಛತೆ',
      'Clear filters': 'ಫಿಲ್ಟರ್‌ಗಳನ್ನು ತೆರವುಗೊಳಿಸಿ',
      'Clear search': 'ಹುಡುಕಾಟ ತೆರವುಗೊಳಿಸಿ',
      'Clinical Details & Telemetry:': 'ಕ್ಲಿನಿಕಲ್ ವಿವರಗಳು ಮತ್ತು ಟೆಲಿಮೆಟ್ರಿ:',
      'Close': 'ಮುಚ್ಚಿ',
      'Collapse': 'ಕುಗ್ಗಿಸು',
      'Combined': 'ಸಂಯೋಜಿತ',
      'Combined activity': 'ಸಂಯೋಜಿತ ಚಟುವಟಿಕೆ',
      'Comment': 'ಕಾಮೆಂಟ್ ಮಾಡಿ',
      'Company': 'ಕಂಪನಿ',
      'Compare Reports': 'ವರದಿಗಳನ್ನು ಹೋಲಿಕೆ ಮಾಡಿ',
      'Compare any two saved body-composition reports.':
          'ಯಾವುದೇ ಎರಡು ಉಳಿಸಿದ ದೇಹ-ಸಂಯೋಜನೆ ವರದಿಗಳನ್ನು ಹೋಲಿಕೆ ಮಾಡಿ.',
      'Comparison actions': 'ಹೋಲಿಕೆ ಕ್ರಿಯೆಗಳು',
      'Comparison deleted.': 'ಹೋಲಿಕೆ ಅಳಿಸಲಾಗಿದೆ.',
      'Comparison period': 'ಹೋಲಿಕೆ ಅವಧಿ',
      'Comparison status': 'ಹೋಲಿಕೆ ಸ್ಥಿತಿ',
      'Comparison updated.': 'ಹೋಲಿಕೆಯನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ.',
      'Comparison values come from these two saved health reports. Choose the report whose measurements you want to correct.':
          'ಹೋಲಿಕೆ ಮೌಲ್ಯಗಳು ಈ ಎರಡು ಉಳಿಸಿದ ಆರೋಗ್ಯ ವರದಿಗಳಿಂದ ಬರುತ್ತವೆ. ನೀವು ಸರಿಪಡಿಸಲು ಬಯಸುವ ಅಳತೆಗಳ ವರದಿಯನ್ನು ಆರಿಸಿ.',
      'Comparisons': 'ಹೋಲಿಕೆಗಳು',
      'Compete': 'ಸ್ಪರ್ಧಿಸಿ',
      'Compete with users in fun activities.':
          'ಮೋಜಿನ ಚಟುವಟಿಕೆಗಳಲ್ಲಿ ಬಳಕೆದಾರರೊಂದಿಗೆ ಸ್ಪರ್ಧಿಸಿ.',
      'Complete': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
      'Complete a Gym Access workout to see your checklist, session facts, and estimated workout insights here.':
          'ನಿಮ್ಮ ಪರಿಶೀಲನಾಪಟ್ಟಿ, ಅಧಿವೇಶನದ ಸಂಗತಿಗಳು ಮತ್ತು ಅಂದಾಜು ತಾಲೀಮು ಒಳನೋಟಗಳನ್ನು ಇಲ್ಲಿ ನೋಡಲು ಜಿಮ್ ಪ್ರವೇಶ ತಾಲೀಮು ಪೂರ್ಣಗೊಳಿಸಿ.',
      'Completed': 'ಪೂರ್ಣಗೊಂಡಿದೆ',
      'Completion': 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆ',
      'Configure daily health targets below. Your custom goals directly update the Wellness Meter calculations and recommendations.':
          'ದೈನಂದಿನ ಆರೋಗ್ಯ ಗುರಿಗಳನ್ನು ಕೆಳಗೆ ಕಾನ್ಫಿಗರ್ ಮಾಡಿ. ನಿಮ್ಮ ಕಸ್ಟಮ್ ಗುರಿಗಳು ವೆಲ್‌ನೆಸ್ ಮೀಟರ್ ಲೆಕ್ಕಾಚಾರಗಳು ಮತ್ತು ಶಿಫಾರಸುಗಳನ್ನು ನೇರವಾಗಿ ನವೀಕರಿಸುತ್ತವೆ.',
      'Configure which alerts you would like to receive. These settings are synchronized across your devices.':
          'ನೀವು ಯಾವ ಎಚ್ಚರಿಕೆಗಳನ್ನು ಸ್ವೀಕರಿಸಲು ಬಯಸುತ್ತೀರಿ ಎಂಬುದನ್ನು ಕಾನ್ಫಿಗರ್ ಮಾಡಿ. ಈ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನಿಮ್ಮ ಸಾಧನಗಳಲ್ಲಿ ಸಿಂಕ್ರೊನೈಸ್ ಮಾಡಲಾಗಿದೆ.',
      'Confirm AI processing consent': 'AI ಸಂಸ್ಕರಣಾ ಸಮ್ಮತಿಯನ್ನು ದೃಢೀಕರಿಸಿ',
      'Confirm consent': 'ಒಪ್ಪಿಗೆಯನ್ನು ದೃಢೀಕರಿಸಿ',
      'Confirmed value': 'ದೃಢೀಕರಿಸಿದ ಮೌಲ್ಯ',
      'Connect': 'ಸಂಪರ್ಕಿಸಿ',
      'Connect Health Connect': 'ಕನೆಕ್ಟ್ ಹೆಲ್ತ್ ಕನೆಕ್ಟ್',
      'Connect Health Services': 'ಆರೋಗ್ಯ ಸೇವೆಗಳನ್ನು ಸಂಪರ್ಕಿಸಿ',
      'Connected': 'ಸಂಪರ್ಕಿಸಲಾಗಿದೆ',
      'Connected Successfully': 'ಯಶಸ್ವಿಯಾಗಿ ಸಂಪರ್ಕಿಸಲಾಗಿದೆ',
      'Connected to Health Services': 'ಆರೋಗ್ಯ ಸೇವೆಗಳಿಗೆ ಸಂಪರ್ಕಗೊಂಡಿದೆ',
      'Connection Progress': 'ಸಂಪರ್ಕ ಪ್ರಗತಿ',
      'Connection refused': 'ಸಂಪರ್ಕ ನಿರಾಕರಿಸಲಾಗಿದೆ',
      'Consent & Authorization': 'ಸಮ್ಮತಿ ಮತ್ತು ಅಧಿಕಾರ',
      'Consent Active - Tap to Revoke':
          'ಸಮ್ಮತಿ ಸಕ್ರಿಯ - ಹಿಂತೆಗೆದುಕೊಳ್ಳಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
      'Consent Form: Medical Records Sync':
          'ಸಮ್ಮತಿ ನಮೂನೆ: ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳ ಸಿಂಕ್',
      'Consistency': 'ಸ್ಥಿರತೆ',
      'Contact added': 'ಸಂಪರ್ಕವನ್ನು ಸೇರಿಸಲಾಗಿದೆ',
      'Contact deleted': 'ಸಂಪರ್ಕವನ್ನು ಅಳಿಸಲಾಗಿದೆ',
      'Contact updated': 'ಸಂಪರ್ಕವನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ',
      'Contacts, services & one-tap alert':
          'ಸಂಪರ್ಕಗಳು, ಸೇವೆಗಳು ಮತ್ತು ಒಂದು-ಟ್ಯಾಪ್ ಎಚ್ಚರಿಕೆ',
      'Content-Type': 'ವಿಷಯ-ಪ್ರಕಾರ',
      'Continue': 'ಮುಂದುವರಿಸಿ',
      'Continue with Apple': 'ಆಪಲ್‌ನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ',
      'Continue with Google': 'Google ನೊಂದಿಗೆ ಮುಂದುವರಿಸಿ',
      'Copy JSON': 'JSON ನಕಲಿಸಿ',
      'Core': 'ಕೋರ್',
      'Correct body & recovery data': 'ಸರಿಯಾದ ದೇಹ ಮತ್ತು ಚೇತರಿಕೆ ಡೇಟಾ',
      'Correct missed or extra work from this session. Assigned exercises cannot be removed. Extra work is listed separately and does not raise plan completion.':
          'ಈ ಅವಧಿಯಿಂದ ತಪ್ಪಿಸಿಕೊಂಡ ಅಥವಾ ಹೆಚ್ಚುವರಿ ಕೆಲಸವನ್ನು ಸರಿಪಡಿಸಿ. ನಿಯೋಜಿಸಲಾದ ವ್ಯಾಯಾಮಗಳನ್ನು ತೆಗೆದುಹಾಕಲಾಗುವುದಿಲ್ಲ. ಹೆಚ್ಚುವರಿ ಕೆಲಸವನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಪಟ್ಟಿ ಮಾಡಲಾಗಿದೆ ಮತ್ತು ಯೋಜನೆ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯನ್ನು ಹೆಚ್ಚಿಸುವುದಿಲ್ಲ.',
      'Could not book this slot.': 'ಈ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not complete checkout.': 'ಚೆಕ್ಔಟ್ ಪೂರ್ಣಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not complete the workout session. Please try again.':
          'ವ್ಯಾಯಾಮ ಅವಧಿಯನ್ನು ಪೂರ್ಣಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Could not create the PDF report. Please try again.':
          'PDF ವರದಿಯನ್ನು ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Could not fetch ID token': 'ಐಡಿ ಟೋಕನ್ ಪಡೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load SOS data': 'SOS ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load facilities.': 'ಸೌಲಭ್ಯಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load graph': 'ಗ್ರಾಫ್ ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load organizations': 'ಸಂಸ್ಥೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load organizations.': 'ಸಂಸ್ಥೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load the exercise library.':
          'ವ್ಯಾಯಾಮ ಲೈಬ್ರರಿಯನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load water logs':
          'ನೀರಿನ ಲಾಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load workout reports':
          'ವ್ಯಾಯಾಮ ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load your chat history. Please try again.':
          'ನಿಮ್ಮ ಚಾಟ್ ಇತಿಹಾಸವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Could not load your check-in history.':
          'ನಿಮ್ಮ ಚೆಕ್-ಇನ್ ಇತಿಹಾಸವನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load your comparisons':
          'ನಿಮ್ಮ ಹೋಲಿಕೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not load your health reports':
          'ನಿಮ್ಮ ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not play this exercise video.':
          'ಈ ವ್ಯಾಯಾಮ ವೀಡಿಯೊವನ್ನು ಪ್ಲೇ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not refresh the exercise library.':
          'ವ್ಯಾಯಾಮ ಲೈಬ್ರರಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not save the workout correction.':
          'ವ್ಯಾಯಾಮ ತಿದ್ದುಪಡಿಯನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not save your language. Please try again.':
          'ನಿಮ್ಮ ಭಾಷೆಯನ್ನು ಉಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Could not start the demonstration video.':
          'ಪ್ರದರ್ಶನ ವೀಡಿಯೊವನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not start the workout.': 'ವ್ಯಾಯಾಮವನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not submit workout feedback. Try again.':
          'ವ್ಯಾಯಾಮದ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಸಲ್ಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Could not take the photo.': 'ಫೋಟೋ ತೆಗೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Could not update the facility privacy setting.':
          'ಸೌಲಭ್ಯದ ಗೌಪ್ಯತಾ ಸೆಟ್ಟಿಂಗ್ ಅನ್ನು ನವೀಕರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Create Account': 'ಖಾತೆ ರಚಿಸಿ',
      'Create your account': 'ನಿಮ್ಮ ಖಾತೆಯನ್ನು ರಚಿಸಿ',
      'Critical': 'ನಿರ್ಣಾಯಕ',
      'Cup': 'ಕಪ್',
      'Custom': 'ಕಸ್ಟಮ್',
      'Custom Amount': 'ಕಸ್ಟಮ್ ಮೊತ್ತ',
      'Custom condition': 'ಕಸ್ಟಮ್ ಸ್ಥಿತಿ',
      'Custom exercise': 'ಕಸ್ಟಮ್ ವ್ಯಾಯಾಮ',
      'DAILY DIGEST': 'ದೈನಂದಿನ ಜೀರ್ಣಕ್ರಿಯೆ',
      'DAILY WELLNESS': 'ದೈನಂದಿನ ಯೋಗಕ್ಷೇಮ',
      'DEBUG_LAN_API_BASE_URL': 'ಡೆಬಗ್_ಲ್ಯಾನ್_ಎಪಿಐ_ಬೇಸ್_ಯುಆರ್ಎಲ್',
      'DELETE': 'ಅಳಿಸಿ',
      'DETAILED RECORD HISTORY': 'ವಿವರವಾದ ದಾಖಲೆ ಇತಿಹಾಸ',
      'DOB': 'ಜನ್ಮ ದಿನಾಂಕ',
      'Daily': 'ದೈನಂದಿನ',
      'Daily Alerts': 'ದೈನಂದಿನ ಎಚ್ಚರಿಕೆಗಳು',
      'Daily Step Goal 👣': 'ದೈನಂದಿನ ಹೆಜ್ಜೆ ಗುರಿ 👣',
      'Daily Steps': 'ದೈನಂದಿನ ಹೆಜ್ಜೆಗಳು',
      'Daily Steps & Distance': 'ದೈನಂದಿನ ಹೆಜ್ಜೆಗಳು ಮತ್ತು ದೂರ',
      'Daily Wellness Reminder': 'ದೈನಂದಿನ ಸ್ವಾಸ್ಥ್ಯ ಜ್ಞಾಪನೆ',
      'Daily Wellness Summary': 'ದೈನಂದಿನ ಸ್ವಾಸ್ಥ್ಯ ಸಾರಾಂಶ',
      'Dark': 'ಕತ್ತಲೆ',
      'Date not recorded': 'ದಿನಾಂಕ ದಾಖಲಾಗಿಲ್ಲ',
      'Date of Birth': 'ಹುಟ್ಟಿದ ದಿನಾಂಕ',
      'Date of birth': 'ಹುಟ್ಟಿದ ದಿನಾಂಕ',
      'Date:': 'ದಿನಾಂಕ:',
      'Day': 'ದಿನ',
      'Day-by-Day Logs (Last 7 Days)': 'ದಿನನಿತ್ಯದ ದಾಖಲೆಗಳು (ಕಳೆದ 7 ದಿನಗಳು)',
      'Dec': 'ಡಿಸೆಂಬರ್',
      'Decline': 'ನಿರಾಕರಿಸು',
      'Delete': 'ಅಳಿಸಿ',
      'Delete chat': 'ಚಾಟ್ ಅಳಿಸಿ',
      'Delete chat?': 'ಚಾಟ್ ಅಳಿಸುವುದೇ?',
      'Delete comparison': 'ಹೋಲಿಕೆ ಅಳಿಸಿ',
      'Delete comparison?': 'ಹೋಲಿಕೆಯನ್ನು ಅಳಿಸುವುದೇ?',
      'Delete contact?': 'ಸಂಪರ್ಕವನ್ನು ಅಳಿಸುವುದೇ?',
      'Delete health report?': 'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಅಳಿಸುವುದೇ?',
      'Delete report': 'ವರದಿಯನ್ನು ಅಳಿಸಿ',
      'Describe your meal': 'ನಿಮ್ಮ ಊಟವನ್ನು ವಿವರಿಸಿ',
      'Desk job, little to no exercise in a typical week.':
          'ಮೇಜಿನ ಕೆಲಸ, ವಾರದಲ್ಲಿ ಕಡಿಮೆ ಅಥವಾ ಯಾವುದೇ ವ್ಯಾಯಾಮವಿಲ್ಲ.',
      'Detail': 'ವಿವರ',
      'Detailed front and back anatomy map. All listed targets are highlighted in red.':
          'ವಿವರವಾದ ಮುಂಭಾಗ ಮತ್ತು ಹಿಂಭಾಗದ ಅಂಗರಚನಾಶಾಸ್ತ್ರ ನಕ್ಷೆ. ಪಟ್ಟಿ ಮಾಡಲಾದ ಎಲ್ಲಾ ಗುರಿಗಳನ್ನು ಕೆಂಪು ಬಣ್ಣದಲ್ಲಿ ಹೈಲೈಟ್ ಮಾಡಲಾಗಿದೆ.',
      'Device sync error': 'ಸಾಧನ ಸಿಂಕ್ ದೋಷ',
      'Diabetes': 'ಮಧುಮೇಹ',
      'Dietary preference': 'ಆಹಾರ ಪದ್ಧತಿಯ ಆದ್ಯತೆ',
      'Dietitian · Nutrition guidance': 'ಆಹಾರ ತಜ್ಞರು · ಪೌಷ್ಟಿಕಾಂಶ ಮಾರ್ಗದರ್ಶನ',
      'Directions could not be opened.':
          'ನಿರ್ದೇಶನಗಳನ್ನು ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Disabled': 'ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ',
      'Disconnect': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಳಿಸಿ',
      'Disconnected': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ',
      'Displaying static mockup info.':
          'ಸ್ಥಿರ ಮಾದರಿ ಮಾಹಿತಿಯನ್ನು ಪ್ರದರ್ಶಿಸಲಾಗುತ್ತಿದೆ.',
      'Do you feel any pain?': 'ನಿಮಗೆ ನೋವು ಅನಿಸುತ್ತಿದೆಯೇ?',
      'Do you feel any progress?': 'ನಿಮಗೆ ಏನಾದರೂ ಪ್ರಗತಿ ಅನಿಸುತ್ತಿದೆಯೇ?',
      'Don\'t have an account?': 'ಖಾತೆ ಇಲ್ಲವೇ?',
      'Done': 'ಮುಗಿದಿದೆ',
      'Done Editing': 'ಸಂಪಾದನೆ ಮುಗಿದಿದೆ',
      'Dose: 0.5 mL, Route: Intramuscular (IM) Left Deltoid. Manufacturer: Sanofi Pasteur. Lot: TD8932A. Next booster recommended in 10 years.':
          'ಡೋಸ್: 0.5 ಮಿಲಿ, ಮಾರ್ಗ: ಇಂಟ್ರಾಮಸ್ಕುಲರ್ (IM) ಎಡ ಡೆಲ್ಟಾಯ್ಡ್. ತಯಾರಕ: ಸನೋಫಿ ಪಾಶ್ಚರ್. ಲಾಟ್: TD8932A. 10 ವರ್ಷಗಳಲ್ಲಿ ಮುಂದಿನ ಬೂಸ್ಟರ್ ಅನ್ನು ಶಿಫಾರಸು ಮಾಡಲಾಗಿದೆ.',
      'Down': 'ಕೆಳಗೆ',
      'Download': 'ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Download Health Connect': 'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Download PDF': 'PDF ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Download completion summary':
          'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಸಾರಾಂಶವನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Download progress PDF': 'ಪ್ರಗತಿ PDF ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Dumbbells': 'ಡಂಬ್ಬೆಲ್ಸ್',
      'Duplicate or incorrect session': 'ನಕಲು ಅಥವಾ ತಪ್ಪಾದ ಅಧಿವೇಶನ',
      'Duration': 'ಅವಧಿ',
      'Duration in minutes (optional)': 'ನಿಮಿಷಗಳಲ್ಲಿ ಅವಧಿ (ಐಚ್ಛಿಕ)',
      'ECG Rhythm Check': 'ಇಸಿಜಿ ರಿದಮ್ ಚೆಕ್',
      'ECG Rhythm Recording': 'ಇಸಿಜಿ ರಿದಮ್ ರೆಕಾರ್ಡಿಂಗ್',
      'EDITED BY MEMBER': 'ಸದಸ್ಯರು ಸಂಪಾದಿಸಿದ್ದಾರೆ',
      'EMAIL ADDRESS': 'ಇಮೇಲ್ ವಿಳಾಸ',
      'EMERGENCY CONTACTS': 'ತುರ್ತು ಸಂಪರ್ಕಗಳು',
      'EMERGENCY SERVICES': 'ತುರ್ತು ಸೇವೆಗಳು',
      'EST. CALORIES BURNED': 'ಸುಟ್ಟ ಅಂದಾಜು ಕ್ಯಾಲೋರಿಗಳು',
      'Each additional measurement needs a label and number.':
          'ಪ್ರತಿಯೊಂದು ಹೆಚ್ಚುವರಿ ಅಳತೆಗೆ ಲೇಬಲ್ ಮತ್ತು ಸಂಖ್ಯೆಯ ಅಗತ್ಯವಿದೆ.',
      'Each card shows the earlier value, latest value, and exact change.':
          'ಪ್ರತಿಯೊಂದು ಕಾರ್ಡ್ ಹಿಂದಿನ ಮೌಲ್ಯ, ಇತ್ತೀಚಿನ ಮೌಲ್ಯ ಮತ್ತು ನಿಖರವಾದ ಬದಲಾವಣೆಯನ್ನು ತೋರಿಸುತ್ತದೆ.',
      'Earlier': 'ಹಿಂದಿನದು',
      'Earlier conversation': 'ಹಿಂದಿನ ಸಂಭಾಷಣೆ',
      'Earlier report': 'ಹಿಂದಿನ ವರದಿ',
      'Earn achievements and premium badges.':
          'ಸಾಧನೆಗಳು ಮತ್ತು ಪ್ರೀಮಿಯಂ ಬ್ಯಾಡ್ಜ್‌ಗಳನ್ನು ಗಳಿಸಿ.',
      'Easy on the eyes at night': 'ರಾತ್ರಿಯಲ್ಲಿ ಕಣ್ಣುಗಳಿಗೆ ಸುಲಭ',
      'Edit': 'ಸಂಪಾದಿಸಿ',
      'Edit Contact': 'ಸಂಪರ್ಕವನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit Profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
      'Edit Water Log': 'ನೀರಿನ ಲಾಗ್ ಅನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit a completed session': 'ಪೂರ್ಣಗೊಂಡ ಅಧಿವೇಶನವನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit comparison': 'ಹೋಲಿಕೆ ಸಂಪಾದಿಸಿ',
      'Edit comparison reports': 'ಹೋಲಿಕೆ ವರದಿಗಳನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit details': 'ವಿವರಗಳನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit health report': 'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit member-entered workout': 'ಸದಸ್ಯರು ನಮೂದಿಸಿದ ವ್ಯಾಯಾಮವನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit profile': 'ಪ್ರೊಫೈಲ್ ಸಂಪಾದಿಸಿ',
      'Edit report': 'ವರದಿಯನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit weekly workouts': 'ವಾರದ ವ್ಯಾಯಾಮಗಳನ್ನು ಸಂಪಾದಿಸಿ',
      'Edit workout': 'ವ್ಯಾಯಾಮವನ್ನು ಸಂಪಾದಿಸಿ',
      'Email': 'ಇಮೇಲ್',
      'Emergency': 'ತುರ್ತು ಪರಿಸ್ಥಿತಿ',
      'Empty server response': 'ಖಾಲಿ ಸರ್ವರ್ ಪ್ರತಿಕ್ರಿಯೆ',
      'Enable Health Connect Sync option':
          'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಸಿಂಕ್ ಆಯ್ಕೆಯನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಿ',
      'Enabled': 'ಸಕ್ರಿಯಗೊಳಿಸಲಾಗಿದೆ',
      'Encrypting medical health profile...':
          'ವೈದ್ಯಕೀಯ ಆರೋಗ್ಯ ಪ್ರೊಫೈಲ್ ಅನ್ನು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'Ended': 'ಕೊನೆಗೊಂಡಿದೆ',
      'Ends': 'ಕೊನೆಗೊಳ್ಳುತ್ತದೆ',
      'Ends today': 'ಇಂದು ಕೊನೆಗೊಳ್ಳುತ್ತದೆ',
      'Endurance': 'ಸಹಿಷ್ಣುತೆ',
      'English': 'ಇಂಗ್ಲೀಷ್',
      'Enter a new password for your account (minimum 6 characters).':
          'ನಿಮ್ಮ ಖಾತೆಗೆ ಹೊಸ ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ (ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳು).',
      'Enter a work email': 'ಕೆಲಸದ ಇಮೇಲ್ ನಮೂದಿಸಿ',
      'Enter amount (ml)': 'ಮೊತ್ತವನ್ನು ನಮೂದಿಸಿ (ಮಿ.ಲೀ)',
      'Enter condition name': 'ಸ್ಥಿತಿಯ ಹೆಸರನ್ನು ನಮೂದಿಸಿ',
      'Enter the 6-digit code we emailed you. It expires in 15 minutes.':
          'ನಾವು ನಿಮಗೆ ಇಮೇಲ್ ಮಾಡಿದ 6-ಅಂಕಿಯ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ. ಇದು 15 ನಿಮಿಷಗಳಲ್ಲಿ ಮುಕ್ತಾಯಗೊಳ್ಳುತ್ತದೆ.',
      'Enter the Code': 'ಕೋಡ್ ನಮೂದಿಸಿ',
      'Enter the facility code first.': 'ಮೊದಲು ಸೌಲಭ್ಯ ಕೋಡ್ ನಮೂದಿಸಿ.',
      'Enter the verification code.': 'ಪರಿಶೀಲನಾ ಕೋಡ್ ನಮೂದಿಸಿ.',
      'Enter value': 'ಮೌಲ್ಯವನ್ನು ನಮೂದಿಸಿ',
      'Enter volume (ml)': 'ವಾಲ್ಯೂಮ್ (ಮಿಲಿ) ನಮೂದಿಸಿ',
      'Enter your registered email address to receive a 6-digit OTP code.':
          '6-ಅಂಕಿಯ OTP ಕೋಡ್ ಸ್ವೀಕರಿಸಲು ನಿಮ್ಮ ನೋಂದಾಯಿತ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ.',
      'Equipment (pick any)': 'ಸಲಕರಣೆಗಳು (ಯಾವುದನ್ನಾದರೂ ಆರಿಸಿ)',
      'Equipment and resources': 'ಸಲಕರಣೆಗಳು ಮತ್ತು ಸಂಪನ್ಮೂಲಗಳು',
      'Est. energy burn': 'ಅಂದಾಜು ಶಕ್ತಿ ದಹನ',
      'Establishing secure local environment...':
          'ಸುರಕ್ಷಿತ ಸ್ಥಳೀಯ ಪರಿಸರವನ್ನು ಸ್ಥಾಪಿಸುವುದು...',
      'Estimate nutrition': 'ಪೌಷ್ಟಿಕಾಂಶವನ್ನು ಅಂದಾಜು ಮಾಡಿ',
      'Estimated calories': 'ಅಂದಾಜು ಕ್ಯಾಲೊರಿಗಳು',
      'Estimated calories, intensity, summary, and recovery guidance are AI-generated estimates from this session\'s duration and workout plan. They are not medical advice.':
          'ಅಂದಾಜು ಕ್ಯಾಲೋರಿಗಳು, ತೀವ್ರತೆ, ಸಾರಾಂಶ ಮತ್ತು ಚೇತರಿಕೆ ಮಾರ್ಗದರ್ಶನವು ಈ ಅವಧಿಯ ಅವಧಿ ಮತ್ತು ವ್ಯಾಯಾಮ ಯೋಜನೆಯಿಂದ AI- ರಚಿತವಾದ ಅಂದಾಜುಗಳಾಗಿವೆ. ಅವು ವೈದ್ಯಕೀಯ ಸಲಹೆಯಲ್ಲ.',
      'Estimated calories, intensity, summary, and recovery guidance are generated from this session\'s duration and workout plan. They are not medical advice.':
          'ಅಂದಾಜು ಕ್ಯಾಲೋರಿಗಳು, ತೀವ್ರತೆ, ಸಾರಾಂಶ ಮತ್ತು ಚೇತರಿಕೆ ಮಾರ್ಗದರ್ಶನವನ್ನು ಈ ಅವಧಿಯ ಅವಧಿ ಮತ್ತು ವ್ಯಾಯಾಮ ಯೋಜನೆಯಿಂದ ರಚಿಸಲಾಗಿದೆ. ಅವು ವೈದ್ಯಕೀಯ ಸಲಹೆಯಲ್ಲ.',
      'Estimating your meal…': 'ನಿಮ್ಮ ಊಟವನ್ನು ಅಂದಾಜು ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'Excellent': 'ಅತ್ಯುತ್ತಮ',
      'Exception:': 'ವಿನಾಯಿತಿ:',
      'Exercise': 'ವ್ಯಾಯಾಮ',
      'Exercise Duration Target ⏱️': 'ವ್ಯಾಯಾಮದ ಅವಧಿಯ ಗುರಿ ⏱️',
      'Exercise Library': 'ವ್ಯಾಯಾಮ ಗ್ರಂಥಾಲಯ',
      'Exercise name': 'ವ್ಯಾಯಾಮದ ಹೆಸರು',
      'Exercise video': 'ವ್ಯಾಯಾಮ ವೀಡಿಯೊ',
      'Exercise videos': 'ವ್ಯಾಯಾಮ ವೀಡಿಯೊಗಳು',
      'Exercise videos are not available yet.':
          'ವ್ಯಾಯಾಮದ ವೀಡಿಯೊಗಳು ಇನ್ನೂ ಲಭ್ಯವಿಲ್ಲ.',
      'Experience': 'ಅನುಭವ',
      'Explicit consent required to access clinical reports.':
          'ಕ್ಲಿನಿಕಲ್ ವರದಿಗಳನ್ನು ಪಡೆಯಲು ಸ್ಪಷ್ಟ ಒಪ್ಪಿಗೆ ಅಗತ್ಯವಿದೆ.',
      'Explore New Challenges': 'ಹೊಸ ಸವಾಲುಗಳನ್ನು ಅನ್ವೇಷಿಸಿ',
      'Extra exercises': 'ಹೆಚ್ಚುವರಿ ವ್ಯಾಯಾಮಗಳು',
      'Extra sets': 'ಹೆಚ್ಚುವರಿ ಸೆಟ್‌ಗಳು',
      'Extra work': 'ಹೆಚ್ಚುವರಿ ಕೆಲಸ',
      'F': 'ಕ',
      'FULL NAME': 'ಪೂರ್ಣ ಹೆಸರು',
      'Facilities are ordered by your preference, recommendations, and visits.':
          'ನಿಮ್ಮ ಆದ್ಯತೆ, ಶಿಫಾರಸುಗಳು ಮತ್ತು ಭೇಟಿಗಳ ಆಧಾರದ ಮೇಲೆ ಸೌಲಭ್ಯಗಳನ್ನು ಆದೇಶಿಸಲಾಗುತ್ತದೆ.',
      'Facility': 'ಸೌಲಭ್ಯ',
      'Facility code': 'ಸೌಲಭ್ಯ ಕೋಡ್',
      'Facility workout': 'ಸೌಲಭ್ಯದ ತಾಲೀಮು',
      'Facility workout-data sharing': 'ಸೌಲಭ್ಯದ ತಾಲೀಮು-ಡೇಟಾ ಹಂಚಿಕೆ',
      'Facility workout-data sharing withdrawn. Manager access ends now, and new bookings and check-ins are blocked until you approve again.':
          'ಸೌಲಭ್ಯದ ತಾಲೀಮು-ಡೇಟಾ ಹಂಚಿಕೆಯನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಲಾಗಿದೆ. ವ್ಯವಸ್ಥಾಪಕರ ಪ್ರವೇಶವು ಈಗ ಕೊನೆಗೊಳ್ಳುತ್ತದೆ ಮತ್ತು ನೀವು ಮತ್ತೆ ಅನುಮೋದಿಸುವವರೆಗೆ ಹೊಸ ಬುಕಿಂಗ್‌ಗಳು ಮತ್ತು ಚೆಕ್-ಇನ್‌ಗಳನ್ನು ನಿರ್ಬಂಧಿಸಲಾಗುತ್ತದೆ.',
      'Failed host lookup': 'ಹೋಸ್ಟ್ ಲುಕಪ್ ವಿಫಲವಾಗಿದೆ',
      'Failed to grant health permissions. Please enable them to sync data.':
          'ಆರೋಗ್ಯ ಅನುಮತಿಗಳನ್ನು ನೀಡುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ. ದಯವಿಟ್ಟು ಅವುಗಳನ್ನು ಡೇಟಾ ಸಿಂಕ್ ಮಾಡಲು ಸಕ್ರಿಯಗೊಳಿಸಿ.',
      'Failed to grant medical access permissions.':
          'ವೈದ್ಯಕೀಯ ಪ್ರವೇಶ ಅನುಮತಿಗಳನ್ನು ನೀಡುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ.',
      'Failed to load trends': 'ಟ್ರೆಂಡ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ.',
      'Fair': 'ನ್ಯಾಯೋಚಿತ',
      'Falling back to sequential fetching.':
          'ಅನುಕ್ರಮ ಪಡೆಯುವಿಕೆಗೆ ಹಿಂತಿರುಗಲಾಗುತ್ತಿದೆ.',
      'Fantastic effort! You\'ve achieved your goal.':
          'ಅದ್ಭುತ ಪ್ರಯತ್ನ! ನೀವು ನಿಮ್ಮ ಗುರಿಯನ್ನು ಸಾಧಿಸಿದ್ದೀರಿ.',
      'Fat': 'ಕೊಬ್ಬು',
      'Fat-free weight': 'ಕೊಬ್ಬು ರಹಿತ ತೂಕ',
      'Feb': 'ಫೆಬ್ರವರಿ',
      'Female': 'ಹೆಣ್ಣು',
      'Finalized': 'ಅಂತಿಮಗೊಳಿಸಲಾಗಿದೆ',
      'Finish later': 'ನಂತರ ಮುಗಿಸಿ',
      'Finish workout?': 'ವ್ಯಾಯಾಮ ಮುಗಿಸಬೇಕೆ?',
      'Fire': 'ಬೆಂಕಿ',
      'Fit the whole report inside the frame. Tap text to focus; keep labels and numbers sharp and glare-free.':
          'ಇಡೀ ವರದಿಯನ್ನು ಫ್ರೇಮ್ ಒಳಗೆ ಹೊಂದಿಸಿ. ಕೇಂದ್ರೀಕರಿಸಲು ಪಠ್ಯವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ; ಲೇಬಲ್‌ಗಳು ಮತ್ತು ಸಂಖ್ಯೆಗಳನ್ನು ತೀಕ್ಷ್ಣವಾಗಿ ಮತ್ತು ಪ್ರಜ್ವಲಿಸುವಿಕೆ-ಮುಕ್ತವಾಗಿ ಇರಿಸಿ.',
      'Fitness App Synced': 'ಫಿಟ್‌ನೆಸ್ ಅಪ್ಲಿಕೇಶನ್ ಸಿಂಕ್ ಮಾಡಲಾಗಿದೆ',
      'Flagged': 'ಫ್ಲ್ಯಾಗ್ ಮಾಡಲಾಗಿದೆ',
      'Flash is not available on this camera.':
          'ಈ ಕ್ಯಾಮೆರಾದಲ್ಲಿ ಫ್ಲ್ಯಾಶ್ ಲಭ್ಯವಿಲ್ಲ.',
      'Flask': 'ಫ್ಲಾಸ್ಕ್',
      'Forearms': 'ಮುಂಗೈಗಳು',
      'Forgot Password?': 'ಪಾಸ್ವರ್ಡ್ ಮರೆತಿರಾ?',
      'Forward 10 seconds': '10 ಸೆಕೆಂಡುಗಳು ಮುಂದಕ್ಕೆ',
      'Fri': 'ಶುಕ್ರ',
      'Friday': 'ಶುಕ್ರವಾರ',
      'From Exercise Library': 'ವ್ಯಾಯಾಮ ಗ್ರಂಥಾಲಯದಿಂದ',
      'Front': 'ಮುಂಭಾಗ',
      'Full': 'ಪೂರ್ಣ',
      'Full Name': 'ಪೂರ್ಣ ಹೆಸರು',
      'Full body': 'ಪೂರ್ಣ ದೇಹ',
      'Full gym': 'ಪೂರ್ಣ ಜಿಮ್',
      'Full legal name': 'ಪೂರ್ಣ ಕಾನೂನು ಹೆಸರು',
      'Full name': 'ಪೂರ್ಣ ಹೆಸರು',
      'Full-body training': 'ಪೂರ್ಣ ದೇಹದ ತರಬೇತಿ',
      'GET': 'ಪಡೆಯಿರಿ',
      'GOAL ACHIEVED': 'ಗುರಿ ಸಾಧಿಸಲಾಗಿದೆ',
      'GYM': 'ಜಿಮ್',
      'GYM ACTIVE': 'ಜಿಮ್ ಸಕ್ರಿಯ',
      'GYM CHECK-IN': 'ಜಿಮ್ ಚೆಕ್-ಇನ್',
      'Gender': 'ಲಿಂಗ',
      'General fitness': 'ಸಾಮಾನ್ಯ ಫಿಟ್‌ನೆಸ್',
      'Generate a meal plan': 'ಊಟದ ಯೋಜನೆಯನ್ನು ರಚಿಸಿ',
      'Generate a plan for today': 'ಇವತ್ತಿಗೆ ಒಂದು ಯೋಜನೆಯನ್ನು ರಚಿಸಿ',
      'Gentle alerts when it\'s time to rest.':
          'ವಿಶ್ರಾಂತಿ ಪಡೆಯುವ ಸಮಯ ಬಂದಾಗ ಸೌಮ್ಯ ಎಚ್ಚರಿಕೆಗಳು.',
      'Get Started': 'ಪ್ರಾರಂಭಿಸಲು ಒತ್ತಿ',
      'Glucose level': 'ಗ್ಲೂಕೋಸ್ ಮಟ್ಟ',
      'Glutes': 'ಗ್ಲುಟ್‌ಗಳು',
      'Go back': 'ಹಿಂತಿರುಗಿ',
      'Go to your Profile tab': 'ನಿಮ್ಮ ಪ್ರೊಫೈಲ್ ಟ್ಯಾಬ್‌ಗೆ ಹೋಗಿ',
      'Goal': 'ಗುರಿ',
      'Goals saved on this device, but couldn\'t sync to the server.':
          'ಈ ಸಾಧನದಲ್ಲಿ ಗುರಿಗಳನ್ನು ಉಳಿಸಲಾಗಿದೆ, ಆದರೆ ಸರ್ವರ್‌ಗೆ ಸಿಂಕ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'Goals saved successfully!': 'ಗುರಿಗಳನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಉಳಿಸಲಾಗಿದೆ!',
      'Good': 'ಒಳ್ಳೆಯದು',
      'Good Afternoon': 'ಶುಭ ಮಧ್ಯಾಹ್ನ',
      'Good Evening': 'ಶುಭ ಸಂಜೆ',
      'Good Morning': 'ಶುಭೋದಯ',
      'Google': 'ಗೂಗಲ್',
      'Google Fit Setup Guide': 'ಗೂಗಲ್ ಫಿಟ್ ಸೆಟಪ್ ಗೈಡ್',
      'Google Fit Sync Steps': 'ಗೂಗಲ್ ಫಿಟ್ ಸಿಂಕ್ ಹಂತಗಳು',
      'Google Health Connect is required to securely aggregate and sync your health records.':
          'ನಿಮ್ಮ ಆರೋಗ್ಯ ದಾಖಲೆಗಳನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಒಟ್ಟುಗೂಡಿಸಲು ಮತ್ತು ಸಿಂಕ್ ಮಾಡಲು Google Health Connect ಅಗತ್ಯವಿದೆ.',
      'Grant': 'ಅನುದಾನ',
      'Grant all Read & Write Permissions requested':
          'ವಿನಂತಿಸಿದ ಎಲ್ಲಾ ಓದಲು ಮತ್ತು ಬರೆಯಲು ಅನುಮತಿಗಳನ್ನು ನೀಡಿ',
      'Great': 'ಗ್ರೇಟ್',
      'Gym': 'ಜಿಮ್',
      'Gym Check-in': 'ಜಿಮ್ ಚೆಕ್-ಇನ್',
      'Gym access': 'ಜಿಮ್ ಪ್ರವೇಶ',
      'HEALTH': 'ಆರೋಗ್ಯ',
      'HEALTH & WELLNESS': 'ಆರೋಗ್ಯ ಮತ್ತು ಸ್ವಾಸ್ಥ್ಯ',
      'HEIGHT': 'ಎತ್ತರ',
      'Hamstrings': 'ಹ್ಯಾಮ್ ಸ್ಟ್ರಿಂಗ್ಸ್',
      'Head/neck': 'ತಲೆ/ಕುತ್ತಿಗೆ',
      'Headers: Authorization: Bearer [token]':
          'ಶೀರ್ಷಿಕೆಗಳು: ಅಧಿಕಾರ: ಬೇರರ್ [ಟೋಕನ್]',
      'Health Connect': 'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್',
      'Health Connect Installed': 'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಸ್ಥಾಪಿಸಲಾಗಿದೆ',
      'Health Connect Required': 'ಆರೋಗ್ಯ ಸಂಪರ್ಕ ಅಗತ್ಯವಿದೆ',
      'Health Connect app is not installed on this device.':
          'ಈ ಸಾಧನದಲ್ಲಿ ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಅಪ್ಲಿಕೇಶನ್ ಅನ್ನು ಸ್ಥಾಪಿಸಲಾಗಿಲ್ಲ.',
      'Health Connect is connected. To view health metrics, please ensure a supported fitness app (like Google Fit) is active and syncing with Health Connect.':
          'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಸಂಪರ್ಕಗೊಂಡಿದೆ. ಆರೋಗ್ಯ ಮೆಟ್ರಿಕ್‌ಗಳನ್ನು ವೀಕ್ಷಿಸಲು, ಬೆಂಬಲಿತ ಫಿಟ್‌ನೆಸ್ ಅಪ್ಲಿಕೇಶನ್ (ಗೂಗಲ್ ಫಿಟ್‌ನಂತಹ) ಸಕ್ರಿಯವಾಗಿದೆ ಮತ್ತು ಹೆಲ್ತ್ ಕನೆಕ್ಟ್‌ನೊಂದಿಗೆ ಸಿಂಕ್ ಆಗುತ್ತಿದೆ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.',
      'Health Connect permissions are already granted.':
          'ಹೆಲ್ತ್ ಕನೆಕ್ಟ್ ಅನುಮತಿಗಳನ್ನು ಈಗಾಗಲೇ ನೀಡಲಾಗಿದೆ.',
      'Health Data Available': 'ಆರೋಗ್ಯ ಡೇಟಾ ಲಭ್ಯವಿದೆ',
      'Health Data Collection': 'ಆರೋಗ್ಯ ದತ್ತಾಂಶ ಸಂಗ್ರಹ',
      'Health Reports': 'ಆರೋಗ್ಯ ವರದಿಗಳು',
      'Health Sync Debugger': 'ಆರೋಗ್ಯ ಸಿಂಕ್ ಡೀಬಗರ್',
      'Health database synced!': 'ಆರೋಗ್ಯ ಡೇಟಾಬೇಸ್ ಸಿಂಕ್ ಮಾಡಲಾಗಿದೆ!',
      'Health goals': 'ಆರೋಗ್ಯ ಗುರಿಗಳು',
      'Health report': 'ಆರೋಗ್ಯ ವರದಿ',
      'Health report deleted.': 'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಅಳಿಸಲಾಗಿದೆ.',
      'Health report updated.': 'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ.',
      'Health report uploaded': 'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿದೆ',
      'Health services connected. Your data will appear shortly.':
          'ಆರೋಗ್ಯ ಸೇವೆಗಳು ಸಂಪರ್ಕಗೊಂಡಿವೆ. ನಿಮ್ಮ ಡೇಟಾ ಶೀಘ್ರದಲ್ಲೇ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತದೆ.',
      'HealthKit initial sync is taking longer than 20 seconds.':
          'ಹೆಲ್ತ್‌ಕಿಟ್ ಆರಂಭಿಕ ಸಿಂಕ್ 20 ಸೆಕೆಂಡುಗಳಿಗಿಂತ ಹೆಚ್ಚು ಸಮಯ ತೆಗೆದುಕೊಳ್ಳುತ್ತಿದೆ.',
      'HealthService configured successfully.':
          'ಆರೋಗ್ಯ ಸೇವೆಯನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಕಾನ್ಫಿಗರ್ ಮಾಡಲಾಗಿದೆ.',
      'Heart Alert': 'ಹೃದಯದ ಎಚ್ಚರಿಕೆ',
      'Heart Condition': 'ಹೃದಯ ಸ್ಥಿತಿ',
      'Heart Rate': 'ಹೃದಯ ಬಡಿತ',
      'Heart Rate Pulse': 'ಹೃದಯ ಬಡಿತ ನಾಡಿಮಿಡಿತ',
      'Height': 'ಎತ್ತರ',
      'Height (cm)': 'ಎತ್ತರ (ಸೆಂ.ಮೀ)',
      'Helpful reminders to support consistent sleep':
          'ಸ್ಥಿರವಾದ ನಿದ್ರೆಯನ್ನು ಬೆಂಬಲಿಸಲು ಸಹಾಯಕವಾದ ಜ್ಞಾಪನೆಗಳು',
      'Hi! I\'m your fitness coach. ✨ Ask me about sleep, nutrition, hydration, or general fitness tips.':
          'ಹಾಯ್! ನಾನು ನಿಮ್ಮ ಫಿಟ್‌ನೆಸ್ ತರಬೇತುದಾರ. ✨ ನಿದ್ರೆ, ಪೋಷಣೆ, ಜಲಸಂಚಯನ ಅಥವಾ ಸಾಮಾನ್ಯ ಫಿಟ್‌ನೆಸ್ ಸಲಹೆಗಳ ಬಗ್ಗೆ ನನ್ನನ್ನು ಕೇಳಿ.',
      'Hide from my summary': 'ನನ್ನ ಸಾರಾಂಶದಿಂದ ಮರೆಮಾಡಿ',
      'Hide from summary': 'ಸಾರಾಂಶದಿಂದ ಮರೆಮಾಡಿ',
      'Hide this session?': 'ಈ ಸೆಷನ್ ಅನ್ನು ಮರೆಮಾಡುವುದೇ?',
      'High': 'ಹೆಚ್ಚಿನ',
      'High blood pressure management': 'ಅಧಿಕ ರಕ್ತದೊತ್ತಡ ನಿರ್ವಹಣೆ',
      'High-protein': 'ಅಧಿಕ ಪ್ರೋಟೀನ್',
      'Hip': 'ಸೊಂಟ',
      'History': 'ಇತಿಹಾಸ',
      'Home': 'ಮರಳಿ ಪ್ರಥಮ ಪುಟಕ್ಕೆ',
      'Home Facility': 'ಮನೆ ಸೌಲಭ್ಯ',
      'How are you feeling today?': 'ಇವತ್ತು ನಿಮಗೆ ಹೇಗನಿಸುತ್ತಿದೆ?',
      'How can I sleep better?': 'ನಾನು ಹೇಗೆ ಚೆನ್ನಾಗಿ ನಿದ್ರಿಸಬಹುದು?',
      'How do you feel after today’s workout?':
          'ಇಂದಿನ ವ್ಯಾಯಾಮದ ನಂತರ ನಿಮಗೆ ಹೇಗನಿಸುತ್ತದೆ?',
      'How to burn 500 kcal?': '500 ಕೆ.ಕೆ.ಎಲ್ ಸುಡುವುದು ಹೇಗೆ?',
      'How was your workout?': 'ನಿಮ್ಮ ವ್ಯಾಯಾಮ ಹೇಗಿತ್ತು?',
      'Hydration Alert': 'ಜಲಸಂಚಯನ ಎಚ್ಚರಿಕೆ',
      'Hydration Alerts': 'ಜಲಸಂಚಯನ ಎಚ್ಚರಿಕೆಗಳು',
      'Hydration Reminders': 'ಜಲಸಂಚಯನ ಜ್ಞಾಪನೆಗಳು',
      'Hydration Tracker': 'ಜಲಸಂಚಯನ ಟ್ರ್ಯಾಕರ್',
      'Hydration Trends': 'ಜಲಸಂಚಯನ ಪ್ರವೃತ್ತಿಗಳು',
      'Hypertension': 'ಅಧಿಕ ರಕ್ತದೊತ್ತಡ',
      'I agree to the': 'ನಾನು ಒಪ್ಪುತ್ತೇನೆ',
      'I consent to my employer receiving only anonymized, aggregate program participation statistics — never my individual health data.':
          'ನನ್ನ ಉದ್ಯೋಗದಾತರು ಅನಾಮಧೇಯಗೊಳಿಸಿದ, ಒಟ್ಟು ಕಾರ್ಯಕ್ರಮದ ಭಾಗವಹಿಸುವಿಕೆಯ ಅಂಕಿಅಂಶಗಳನ್ನು ಮಾತ್ರ ಸ್ವೀಕರಿಸಲು ನಾನು ಸಮ್ಮತಿಸುತ್ತೇನೆ - ನನ್ನ ವೈಯಕ್ತಿಕ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಎಂದಿಗೂ ಸ್ವೀಕರಿಸುವುದಿಲ್ಲ.',
      'I couldn\'t process that.':
          'ನನಗೆ ಅದನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'I don\'t have any of these conditions': 'ನನಗೆ ಈ ಯಾವುದೇ ಷರತ್ತುಗಳಿಲ್ಲ.',
      'I explicitly consent to allow wellnessconnect to access my secure medical records.':
          'ನನ್ನ ಸುರಕ್ಷಿತ ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳನ್ನು ವೆಲ್‌ನೆಸ್‌ಕನೆಕ್ಟ್ ಪ್ರವೇಶಿಸಲು ನಾನು ಸ್ಪಷ್ಟವಾಗಿ ಸಮ್ಮತಿಸುತ್ತೇನೆ.',
      'I forgot to book a slot': 'ನಾನು ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲು ಮರೆತಿದ್ದೇನೆ.',
      'I need help booking a facility slot.':
          'ಸೌಲಭ್ಯ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲು ನನಗೆ ಸಹಾಯ ಬೇಕು.',
      'I would like my care team to review a suitable program for me.':
          'ನನ್ನ ಆರೈಕೆ ತಂಡವು ನನಗೆ ಸೂಕ್ತವಾದ ಕಾರ್ಯಕ್ರಮವನ್ನು ಪರಿಶೀಲಿಸಬೇಕೆಂದು ನಾನು ಬಯಸುತ್ತೇನೆ.',
      'I\'m having trouble connecting right now. Please try again.':
          'ನನಗೆ ಈಗ ಸಂಪರ್ಕಿಸಲು ತೊಂದರೆಯಾಗುತ್ತಿದೆ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'IN': 'ಒಳಗೆ',
      'IN REVIEW': 'ವಿಮರ್ಶೆಯಲ್ಲಿದೆ',
      'Immunization': 'ರೋಗನಿರೋಧಕ ಶಕ್ತಿ',
      'Import PDF': 'PDF ಆಮದು ಮಾಡಿ',
      'Import Screenshot': 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಆಮದು ಮಾಡಿ',
      'In an emergency, tap SOS to notify contacts, or call services directly from the cards above.':
          'ತುರ್ತು ಪರಿಸ್ಥಿತಿಯಲ್ಲಿ, ಸಂಪರ್ಕಗಳಿಗೆ ತಿಳಿಸಲು SOS ಟ್ಯಾಪ್ ಮಾಡಿ ಅಥವಾ ಮೇಲಿನ ಕಾರ್ಡ್‌ಗಳಿಂದ ನೇರವಾಗಿ ಸೇವೆಗಳಿಗೆ ಕರೆ ಮಾಡಿ.',
      'Include food and quantity for a better estimate.':
          'ಉತ್ತಮ ಅಂದಾಜಿಗಾಗಿ ಆಹಾರ ಮತ್ತು ಪ್ರಮಾಣವನ್ನು ಸೇರಿಸಿ.',
      'Individual': 'ವೈಯಕ್ತಿಕ',
      'Initialized/updated local nutrition cache from API':
          'API ನಿಂದ ಸ್ಥಳೀಯ ಪೌಷ್ಟಿಕಾಂಶ ಸಂಗ್ರಹವನ್ನು ಪ್ರಾರಂಭಿಸಲಾಗಿದೆ/ನವೀಕರಿಸಲಾಗಿದೆ',
      'Initializing secure container...':
          'ಸುರಕ್ಷಿತ ಕಂಟೇನರ್ ಅನ್ನು ಪ್ರಾರಂಭಿಸಲಾಗುತ್ತಿದೆ...',
      'Inner thighs': 'ಒಳ ತೊಡೆಗಳು',
      'Instant Check-in': 'ತತ್‌ಕ್ಷಣ ಚೆಕ್-ಇನ್',
      'Instant check-in': 'ತತ್‌ಕ್ಷಣ ಚೆಕ್-ಇನ್',
      'Intense exercise 4-5 times a week, high daily steps.':
          'ವಾರಕ್ಕೆ 4-5 ಬಾರಿ ತೀವ್ರವಾದ ವ್ಯಾಯಾಮ, ದೈನಂದಿನ ಹೆಚ್ಚಿನ ಹೆಜ್ಜೆಗಳು.',
      'Intensity': 'ತೀವ್ರತೆ',
      'Intermediate': 'ಮಧ್ಯಂತರ',
      'Is your workout complete?': 'ನಿಮ್ಮ ವ್ಯಾಯಾಮ ಪೂರ್ಣಗೊಂಡಿದೆಯೇ?',
      'Issue raised to the facility manager.':
          'ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರಿಗೆ ಸಮಸ್ಯೆಯನ್ನು ತಿಳಿಸಲಾಗಿದೆ.',
      'JSON payload copied to clipboard!':
          'JSON ಪೇಲೋಡ್ ಅನ್ನು ಕ್ಲಿಪ್‌ಬೋರ್ಡ್‌ಗೆ ನಕಲಿಸಲಾಗಿದೆ!',
      'Jan': 'ಜನವರಿ',
      'John Doe': 'ಜಾನ್ ಡೋ',
      'Join Challenge': 'ಸವಾಲಿಗೆ ಸೇರಿ',
      'Join a challenge below to start tracking your progress & earning rewards!':
          'ನಿಮ್ಮ ಪ್ರಗತಿಯನ್ನು ಟ್ರ್ಯಾಕ್ ಮಾಡಲು ಮತ್ತು ಬಹುಮಾನಗಳನ್ನು ಗಳಿಸಲು ಕೆಳಗಿನ ಸವಾಲಿನಲ್ಲಿ ಸೇರಿ!',
      'Join company challenges and follow verified scores':
          'ಕಂಪನಿಯ ಸವಾಲುಗಳಿಗೆ ಸೇರಿ ಮತ್ತು ಪರಿಶೀಲಿಸಿದ ಅಂಕಗಳನ್ನು ಅನುಸರಿಸಿ.',
      'Jul': 'ಜುಲೈ',
      'Jul 12': 'ಜುಲೈ 12',
      'Jun': 'ಜೂನ್',
      'Just now': 'ಇದೀಗ',
      'KG': 'ಕೆಜಿ',
      'Keep going, you are close to hitting your goal!':
          'ಮುಂದುವರಿಯಿರಿ, ನೀವು ನಿಮ್ಮ ಗುರಿಯನ್ನು ಮುಟ್ಟುವ ಹಂತಕ್ಕೆ ಹತ್ತಿರವಾಗಿದ್ದೀರಿ!',
      'Keep program': 'ಕಾರ್ಯಕ್ರಮವನ್ನು ಇರಿಸಿ',
      'Keep working': 'ಕೆಲಸ ಮಾಡುತ್ತಲೇ ಇರಿ',
      'Keto': 'ಕೀಟೋ',
      'Knee': 'ಮೊಣಕಾಲು',
      'LBS': 'ಎಲ್‌ಬಿಎಸ್',
      'Lab Results': 'ಪ್ರಯೋಗಾಲಯ ಫಲಿತಾಂಶಗಳು',
      'Label': 'ಲೇಬಲ್',
      'Laboratory': 'ಪ್ರಯೋಗಾಲಯ',
      'Language': 'ಭಾಷೆ',
      'Latest': 'ಇತ್ತೀಚಿನದು',
      'Latest records': 'ಇತ್ತೀಚಿನ ದಾಖಲೆಗಳು',
      'Latest report': 'ಇತ್ತೀಚಿನ ವರದಿ',
      'Lats': 'ಲ್ಯಾಟ್ಸ್',
      'Leaderboard changes and completion status':
          'ಲೀಡರ್‌ಬೋರ್ಡ್ ಬದಲಾವಣೆಗಳು ಮತ್ತು ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಸ್ಥಿತಿ',
      'Less progress': 'ಕಡಿಮೆ ಪ್ರಗತಿ',
      'Library': 'ಗ್ರಂಥಾಲಯ',
      'Lifestyle & Goals': 'ಜೀವನಶೈಲಿ ಮತ್ತು ಗುರಿಗಳು',
      'Light': 'ಬೆಳಕು',
      'Link Apple or Google first': 'ಮೊದಲು Apple ಅಥವಾ Google ಅನ್ನು ಲಿಂಕ್ ಮಾಡಿ',
      'Lipid Panel': 'ಲಿಪಿಡ್ ಪ್ಯಾನಲ್',
      'Lipid Panel (Cardiovascular Screen)':
          'ಲಿಪಿಡ್ ಪ್ಯಾನಲ್ (ಹೃದಯರಕ್ತನಾಳದ ಪರದೆ)',
      'Live': 'ಲೈವ್',
      'Live Activities are turned off for Wellnessconnect. Your workout remains active, but turn them on in iPhone Settings to keep the timer visible outside the app.':
          'Wellnessconnect ಗಾಗಿ ಲೈವ್ ಚಟುವಟಿಕೆಗಳನ್ನು ಆಫ್ ಮಾಡಲಾಗಿದೆ. ನಿಮ್ಮ ವ್ಯಾಯಾಮವು ಸಕ್ರಿಯವಾಗಿರುತ್ತದೆ, ಆದರೆ ಅಪ್ಲಿಕೇಶನ್‌ನ ಹೊರಗೆ ಟೈಮರ್ ಗೋಚರಿಸುವಂತೆ ಮಾಡಲು iPhone ಸೆಟ್ಟಿಂಗ್‌ಗಳಲ್ಲಿ ಅವುಗಳನ್ನು ಆನ್ ಮಾಡಿ.',
      'Loading your plan-aware weekly summary…':
          'ನಿಮ್ಮ ಯೋಜನೆ-ಅರಿವಿನ ವಾರದ ಸಾರಾಂಶವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'Local health service water state reset.':
          'ಸ್ಥಳೀಯ ಆರೋಗ್ಯ ಸೇವೆಯ ನೀರಿನ ಸ್ಥಿತಿಯನ್ನು ಮರುಹೊಂದಿಸಲಾಗಿದೆ.',
      'Log': 'ಲಾಗ್',
      'Log In': 'ಲಾಗ್ ಇನ್ ಮಾಡಿ',
      'Log Meal': 'ಲಾಗ್ ಮೀಲ್',
      'Log a meal ›': 'ಊಟದ ದಾಖಲೆ ›',
      'Log at least 2000 ml of water daily for 7 consecutive days.':
          'ಸತತ 7 ದಿನಗಳವರೆಗೆ ಪ್ರತಿದಿನ ಕನಿಷ್ಠ 2000 ಮಿಲಿ ನೀರನ್ನು ಸೇವಿಸಿ.',
      'Log deleted successfully': 'ಲಾಗ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಅಳಿಸಲಾಗಿದೆ',
      'Log meals to see your trend.':
          'ನಿಮ್ಮ ಪ್ರವೃತ್ತಿಯನ್ನು ನೋಡಲು ಊಟಗಳನ್ನು ಲಾಗ್ ಮಾಡಿ.',
      'Log updated successfully': 'ಲಾಗ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ',
      'Log water & watch the waves rise':
          'ನೀರನ್ನು ಸಂಗ್ರಹಿಸಿ ಮತ್ತು ಅಲೆಗಳು ಏರುವುದನ್ನು ನೋಡಿ',
      'Log your lunch': 'ನಿಮ್ಮ ಊಟದ ದಾಖಲೆಯನ್ನು ಬರೆಯಿರಿ',
      'Logged Date': 'ಲಾಗ್ ಮಾಡಿದ ದಿನಾಂಕ',
      'Logged Day': 'ಲಾಗ್ಡ್ ಡೇ',
      'Login with SSO': 'SSO ನೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಿ',
      'Lose weight': 'ತೂಕ ಇಳಿಸಿ',
      'Low': 'ಕಡಿಮೆ',
      'Low-carb': 'ಕಡಿಮೆ ಕಾರ್ಬ್',
      'Lower back': 'ಬೆನ್ನಿನ ಕೆಳಭಾಗ',
      'Lowercase Letter': 'ಸಣ್ಣ ಅಕ್ಷರ',
      'M': 'ಮ',
      'MEASUREMENT DATE': 'ಅಳತೆ ದಿನಾಂಕ',
      'MEMBER OF': 'ಸದಸ್ಯ',
      'Make Changes': 'ಬದಲಾವಣೆಗಳನ್ನು ಮಾಡಿ',
      'Make sure the report is flat, bright, and in focus, then try again.':
          'ವರದಿಯು ಸಮತಟ್ಟಾಗಿದೆ, ಪ್ರಕಾಶಮಾನವಾಗಿದೆ ಮತ್ತು ಫೋಕಸ್‌ನಲ್ಲಿರುವುದನ್ನು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ, ನಂತರ ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Male': 'ಗಂಡು',
      'Manage AI workout-report sharing':
          'AI ತಾಲೀಮು-ವರದಿ ಹಂಚಿಕೆಯನ್ನು ನಿರ್ವಹಿಸಿ',
      'Manual Log': 'ಹಸ್ತಚಾಲಿತ ಲಾಗ್',
      'Manual Logging': 'ಹಸ್ತಚಾಲಿತ ಲಾಗಿಂಗ್',
      'Manual measurement': 'ಹಸ್ತಚಾಲಿತ ಅಳತೆ',
      'Mar': 'ಮಾರ್ಚ್',
      'Mark complete if this exercise was finished':
          'ಈ ವ್ಯಾಯಾಮ ಮುಗಿದಿದ್ದರೆ ಪೂರ್ಣಗೊಂಡಿದೆ ಎಂದು ಗುರುತಿಸಿ',
      'Mark this exercise when it is finished':
          'ಈ ವ್ಯಾಯಾಮ ಮುಗಿದ ನಂತರ ಅದನ್ನು ಗುರುತಿಸಿ.',
      'Match device setting': 'ಸಾಧನ ಸೆಟ್ಟಿಂಗ್ ಹೊಂದಿಸಿ',
      'May': 'ಮೇ',
      'Meal': 'ಊಟ',
      'Meal Plan': 'ಊಟದ ಯೋಜನೆ',
      'Meal Tracker': 'ಊಟ ಟ್ರ್ಯಾಕರ್',
      'Meal added to today’s tracker.': 'ಇಂದಿನ ಟ್ರ್ಯಾಕರ್‌ಗೆ ಊಟ ಸೇರಿಸಲಾಗಿದೆ.',
      'Meal added to your tracker.': 'ನಿಮ್ಮ ಟ್ರ್ಯಾಕರ್‌ಗೆ ಊಟವನ್ನು ಸೇರಿಸಲಾಗಿದೆ.',
      'Meals, portions & macros': 'ಊಟ, ಭಾಗಗಳು ಮತ್ತು ಮ್ಯಾಕ್ರೋಗಳು',
      'Measurement': 'ಮಾಪನ',
      'Measurement changes': 'ಅಳತೆ ಬದಲಾವಣೆಗಳು',
      'Measurements': 'ಅಳತೆಗಳು',
      'Measurements are shown separately from participation and time elapsed.':
          'ಭಾಗವಹಿಸುವಿಕೆ ಮತ್ತು ಕಳೆದ ಸಮಯದಿಂದ ಅಳತೆಗಳನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ತೋರಿಸಲಾಗಿದೆ.',
      'Measurements compared': 'ಹೋಲಿಸಿದ ಅಳತೆಗಳು',
      'Medical & Clinical Records': 'ವೈದ್ಯಕೀಯ &amp; ಕ್ಲಿನಿಕಲ್ ದಾಖಲೆಗಳು',
      'Medical Data Sharing': 'ವೈದ್ಯಕೀಯ ದತ್ತಾಂಶ ಹಂಚಿಕೆ',
      'Medical Health Profile': 'ವೈದ್ಯಕೀಯ ಆರೋಗ್ಯ ಪ್ರೊಫೈಲ್',
      'Medical Records': 'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು',
      'Medical records access authorized!': 'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳ ಪ್ರವೇಶ ಅಧಿಕೃತ!',
      'Medical records consent revoked and data cleared.':
          'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳ ಒಪ್ಪಿಗೆಯನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ ಮತ್ತು ಡೇಟಾವನ್ನು ತೆರವುಗೊಳಿಸಲಾಗಿದೆ.',
      'Medical records consent revoked.':
          'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳ ಒಪ್ಪಿಗೆಯನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ.',
      'Medifit': 'ಮೆಡಿಫಿಟ್',
      'Meditation': 'ಧ್ಯಾನ',
      'Medium Strength': 'ಮಧ್ಯಮ ಸಾಮರ್ಥ್ಯ',
      'Mednovations': 'ಮೆಡ್ನೋವೇಶನ್ಸ್',
      'Member chose to keep working after leaving the geofence.':
          'ಜಿಯೋಫೆನ್ಸ್ ತೊರೆದ ನಂತರ ಸದಸ್ಯರು ಕೆಲಸ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಲು ಆಯ್ಕೆ ಮಾಡಿಕೊಂಡರು.',
      'Member chose to keep working after the booked slot ended.':
          'ಬುಕ್ ಮಾಡಿದ ಸ್ಲಾಟ್ ಮುಗಿದ ನಂತರವೂ ಸದಸ್ಯರು ಕೆಲಸ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಲು ಆಯ್ಕೆ ಮಾಡಿಕೊಂಡರು.',
      'Member chose to keep working after the hourly prompt.':
          'ಗಂಟೆಯ ಸೂಚನೆಯ ನಂತರ ಸದಸ್ಯರು ಕೆಲಸ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಲು ಆಯ್ಕೆ ಮಾಡಿಕೊಂಡರು.',
      'Member chose to keep working from the workout notification.':
          'ಸದಸ್ಯರು ವ್ಯಾಯಾಮ ಅಧಿಸೂಚನೆಯಿಂದ ಕೆಲಸ ಮಾಡುವುದನ್ನು ಮುಂದುವರಿಸಲು ಆಯ್ಕೆ ಮಾಡಿಕೊಂಡರು.',
      'Member corrected': 'ಸದಸ್ಯರನ್ನು ಸರಿಪಡಿಸಲಾಗಿದೆ',
      'Member-entered': 'ಸದಸ್ಯರಾಗಿ ನೋಂದಾಯಿಸಲಾಗಿದೆ',
      'Metabolic age': 'ಚಯಾಪಚಯ ವಯಸ್ಸು',
      'Metric': 'ಮೆಟ್ರಿಕ್',
      'Mind': 'ಮನಸ್ಸು',
      'Mindfulness': 'ಮನಸ್ಸು',
      'Missed check-in': 'ತಪ್ಪಿದ ಚೆಕ್-ಇನ್',
      'Moderate': 'ಮಧ್ಯಮ',
      'Mon': 'ಸೋಮ',
      'Monday': 'ಸೋಮವಾರ',
      'Month': 'ತಿಂಗಳು',
      'Month-by-Month Logs (Last 3 Months)':
          'ತಿಂಗಳಿನಿಂದ ತಿಂಗಳಿಗೆ ದಾಖಲೆಗಳು (ಕಳೆದ 3 ತಿಂಗಳುಗಳು)',
      'Monthly': 'ಮಾಸಿಕವಾಗಿ',
      'Mood': 'ಮನಸ್ಥಿತಿ',
      'Mood Check-in': 'ಮನಸ್ಥಿತಿ ಪರಿಶೀಲನೆ',
      'More': 'ಇನ್ನಷ್ಟು',
      'More progress': 'ಹೆಚ್ಚಿನ ಪ್ರಗತಿ',
      'Morning briefing summarizing stats and goals':
          'ಅಂಕಿಅಂಶಗಳು ಮತ್ತು ಗುರಿಗಳ ಸಾರಾಂಶದ ಬೆಳಗಿನ ಬ್ರೀಫಿಂಗ್',
      'Move': 'ಸರಿಸಿ',
      'Movement nudges if you remain inactive':
          'ನೀವು ನಿಷ್ಕ್ರಿಯರಾಗಿದ್ದರೆ ಚಲನೆ ತಳ್ಳುತ್ತದೆ',
      'Much better': 'ಹೆಚ್ಚು ಉತ್ತಮವಾಗಿದೆ',
      'Much worse': 'ತುಂಬಾ ಕೆಟ್ಟದಾಗಿದೆ',
      'Muscle Gain': 'ಸ್ನಾಯುಗಳ ಗಳಿಕೆ',
      'Muscle mass': 'ಸ್ನಾಯುವಿನ ದ್ರವ್ಯರಾಶಿ',
      'My Actions': 'ನನ್ನ ಕ್ರಿಯೆಗಳು',
      'My Care Program': 'ನನ್ನ ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ',
      'My upcoming bookings': 'ನನ್ನ ಮುಂಬರುವ ಬುಕಿಂಗ್‌ಗಳು',
      'NUTRITION': 'ಪೋಷಣೆ',
      'Name': 'ಹೆಸರು',
      'Neutral': 'ತಟಸ್ಥ',
      'New': 'ಹೊಸದು',
      'New Password': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್',
      'New broadcast': 'ಹೊಸ ಪ್ರಸಾರ',
      'New conversation': 'ಹೊಸ ಸಂಭಾಷಣೆ',
      'New password': 'ಹೊಸ ಪಾಸ್‌ವರ್ಡ್',
      'Newer report': 'ಹೊಸ ವರದಿ',
      'Next': 'ಮುಂದೆ',
      'Next page': 'ಮುಂದಿನ ಪುಟ',
      'No': 'ಇಲ್ಲ',
      'No Active Challenges': 'ಯಾವುದೇ ಸಕ್ರಿಯ ಸವಾಲುಗಳಿಲ್ಲ',
      'No Onboarding Data': 'ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಡೇಟಾ ಇಲ್ಲ',
      'No actions are scheduled today.':
          'ಇಂದು ಯಾವುದೇ ಕ್ರಮಗಳನ್ನು ನಿಗದಿಪಡಿಸಲಾಗಿಲ್ಲ.',
      'No active challenges': 'ಯಾವುದೇ ಸಕ್ರಿಯ ಸವಾಲುಗಳಿಲ್ಲ',
      'No assigned checklist was stored for this session.':
          'ಈ ಅಧಿವೇಶನಕ್ಕಾಗಿ ಯಾವುದೇ ನಿಯೋಜಿಸಲಾದ ಪರಿಶೀಲನಾಪಟ್ಟಿಯನ್ನು ಸಂಗ್ರಹಿಸಲಾಗಿಲ್ಲ.',
      'No change from the earlier report':
          'ಹಿಂದಿನ ವರದಿಯಿಂದ ಯಾವುದೇ ಬದಲಾವಣೆ ಇಲ್ಲ.',
      'No checklist': 'ಯಾವುದೇ ಪರಿಶೀಲನಾಪಟ್ಟಿ ಇಲ್ಲ',
      'No comparison yet': 'ಇನ್ನೂ ಯಾವುದೇ ಹೋಲಿಕೆ ಇಲ್ಲ.',
      'No comparisons yet. Choose Compare Reports to create one.':
          'ಇನ್ನೂ ಯಾವುದೇ ಹೋಲಿಕೆಗಳಿಲ್ಲ. ಒಂದನ್ನು ರಚಿಸಲು ಹೋಲಿಕೆ ವರದಿಗಳನ್ನು ಆರಿಸಿ.',
      'No daily schedule entries are available for this plan.':
          'ಈ ಯೋಜನೆಗೆ ಯಾವುದೇ ದೈನಂದಿನ ವೇಳಾಪಟ್ಟಿ ನಮೂದುಗಳು ಲಭ್ಯವಿಲ್ಲ.',
      'No email on file': 'ಫೈಲ್‌ನಲ್ಲಿ ಇಮೇಲ್ ಇಲ್ಲ.',
      'No emergency contacts yet': 'ಇನ್ನೂ ಯಾವುದೇ ತುರ್ತು ಸಂಪರ್ಕಗಳಿಲ್ಲ',
      'No exercise videos are available yet.':
          'ಇನ್ನೂ ಯಾವುದೇ ವ್ಯಾಯಾಮದ ವೀಡಿಯೊಗಳು ಲಭ್ಯವಿಲ್ಲ.',
      'No exercises are fully completed. You can still check out.':
          'ಯಾವುದೇ ವ್ಯಾಯಾಮಗಳು ಸಂಪೂರ್ಣವಾಗಿ ಪೂರ್ಣಗೊಂಡಿಲ್ಲ. ನೀವು ಇನ್ನೂ ಪರಿಶೀಲಿಸಬಹುದು.',
      'No expected actions have been generated yet':
          'ಯಾವುದೇ ನಿರೀಕ್ಷಿತ ಕ್ರಿಯೆಗಳು ಇನ್ನೂ ರೂಪುಗೊಂಡಿಲ್ಲ.',
      'No extra exercises added.':
          'ಯಾವುದೇ ಹೆಚ್ಚುವರಿ ವ್ಯಾಯಾಮಗಳನ್ನು ಸೇರಿಸಲಾಗಿಲ್ಲ.',
      'No facilities are linked to your organisation.':
          'ನಿಮ್ಮ ಸಂಸ್ಥೆಗೆ ಯಾವುದೇ ಸೌಲಭ್ಯಗಳು ಸಂಬಂಧಿಸಿಲ್ಲ.',
      'No health measurements were found in that PDF. Try a clear screenshot or scan.':
          'ಆ PDF ನಲ್ಲಿ ಯಾವುದೇ ಆರೋಗ್ಯ ಮಾಪನಗಳು ಕಂಡುಬಂದಿಲ್ಲ. ಸ್ಪಷ್ಟ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅಥವಾ ಸ್ಕ್ಯಾನ್ ಪ್ರಯತ್ನಿಸಿ.',
      'No health reports yet. Add one from Update Your Health.':
          'ಇನ್ನೂ ಯಾವುದೇ ಆರೋಗ್ಯ ವರದಿಗಳಿಲ್ಲ. ಅಪ್‌ಡೇಟ್ ಯುವರ್ ಹೆಲ್ತ್‌ನಿಂದ ಒಂದನ್ನು ಸೇರಿಸಿ.',
      'No health services connected. You can log your metrics manually below:':
          'ಯಾವುದೇ ಆರೋಗ್ಯ ಸೇವೆಗಳು ಸಂಪರ್ಕಗೊಂಡಿಲ್ಲ. ನೀವು ಕೆಳಗೆ ನಿಮ್ಮ ಮೆಟ್ರಿಕ್‌ಗಳನ್ನು ಹಸ್ತಚಾಲಿತವಾಗಿ ಲಾಗ್ ಮಾಡಬಹುದು:',
      'No historical logs available for this range':
          'ಈ ಶ್ರೇಣಿಗೆ ಯಾವುದೇ ಐತಿಹಾಸಿಕ ದಾಖಲೆಗಳು ಲಭ್ಯವಿಲ್ಲ.',
      'No items recorded.': 'ಯಾವುದೇ ಐಟಂಗಳನ್ನು ದಾಖಲಿಸಲಾಗಿಲ್ಲ.',
      'No local onboarding data has been saved yet. Complete onboarding or save a profile first.':
          'ಯಾವುದೇ ಸ್ಥಳೀಯ ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಡೇಟಾವನ್ನು ಇನ್ನೂ ಉಳಿಸಲಾಗಿಲ್ಲ. ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಅನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ ಅಥವಾ ಮೊದಲು ಪ್ರೊಫೈಲ್ ಅನ್ನು ಉಳಿಸಿ.',
      'No logs recorded yet. Tap a quick amount to start.':
          'ಇನ್ನೂ ಯಾವುದೇ ಲಾಗ್‌ಗಳನ್ನು ದಾಖಲಿಸಲಾಗಿಲ್ಲ. ಪ್ರಾರಂಭಿಸಲು ತ್ವರಿತ ಮೊತ್ತವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.',
      'No matching exercises.': 'ಯಾವುದೇ ಹೊಂದಾಣಿಕೆಯ ವ್ಯಾಯಾಮಗಳಿಲ್ಲ.',
      'No medical records found in device database.':
          'ಸಾಧನದ ಡೇಟಾಬೇಸ್‌ನಲ್ಲಿ ಯಾವುದೇ ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು ಕಂಡುಬಂದಿಲ್ಲ.',
      'No new guidance has been published.':
          'ಯಾವುದೇ ಹೊಸ ಮಾರ್ಗಸೂಚಿ ಪ್ರಕಟವಾಗಿಲ್ಲ.',
      'No notifications yet': 'ಇನ್ನೂ ಯಾವುದೇ ಅಧಿಸೂಚನೆಗಳಿಲ್ಲ.',
      'No objectives recorded.': 'ಯಾವುದೇ ಉದ್ದೇಶಗಳನ್ನು ದಾಖಲಿಸಲಾಗಿಲ್ಲ.',
      'No preference': 'ಯಾವುದೇ ಆದ್ಯತೆ ಇಲ್ಲ',
      'No previous programs yet.': 'ಇನ್ನೂ ಯಾವುದೇ ಹಿಂದಿನ ಕಾರ್ಯಕ್ರಮಗಳಿಲ್ಲ.',
      'No published guidance is available for this period.':
          'ಈ ಅವಧಿಗೆ ಯಾವುದೇ ಪ್ರಕಟಿತ ಮಾರ್ಗಸೂಚಿಗಳು ಲಭ್ಯವಿಲ್ಲ.',
      'No readable text was found in that PDF. Try a clear screenshot or scan.':
          'ಆ PDF ನಲ್ಲಿ ಓದಬಹುದಾದ ಯಾವುದೇ ಪಠ್ಯ ಕಂಡುಬಂದಿಲ್ಲ. ಸ್ಪಷ್ಟ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅಥವಾ ಸ್ಕ್ಯಾನ್ ಪ್ರಯತ್ನಿಸಿ.',
      'No rear camera is available on this device.':
          'ಈ ಸಾಧನದಲ್ಲಿ ಯಾವುದೇ ಹಿಂಬದಿಯ ಕ್ಯಾಮೆರಾ ಲಭ್ಯವಿಲ್ಲ.',
      'No refresh token found': 'ಯಾವುದೇ ರಿಫ್ರೆಶ್ ಟೋಕನ್ ಕಂಡುಬಂದಿಲ್ಲ.',
      'No sync logs available yet': 'ಇನ್ನೂ ಯಾವುದೇ ಸಿಂಕ್ ಲಾಗ್‌ಗಳು ಲಭ್ಯವಿಲ್ಲ.',
      'No videos match your search.':
          'ನಿಮ್ಮ ಹುಡುಕಾಟಕ್ಕೆ ಹೊಂದಿಕೆಯಾಗುವ ಯಾವುದೇ ವೀಡಿಯೊಗಳಿಲ್ಲ.',
      'No workout assigned today. You can still check out when you finish.':
          'ಇಂದು ಯಾವುದೇ ವ್ಯಾಯಾಮವನ್ನು ನಿಯೋಜಿಸಲಾಗಿಲ್ಲ. ನೀವು ಮುಗಿಸಿದಾಗಲೂ ಪರಿಶೀಲಿಸಬಹುದು.',
      'No workout checklist was assigned for this session.':
          'ಈ ಅವಧಿಗೆ ಯಾವುದೇ ವ್ಯಾಯಾಮದ ಪರಿಶೀಲನಾಪಟ್ಟಿಯನ್ನು ನಿಯೋಜಿಸಲಾಗಿಲ್ಲ.',
      'No workout reports yet': 'ಇನ್ನೂ ಯಾವುದೇ ವ್ಯಾಯಾಮ ವರದಿಗಳಿಲ್ಲ',
      'Non-binary': 'ಬೈನರಿ ಅಲ್ಲದ',
      'None selected': 'ಯಾವುದನ್ನೂ ಆಯ್ಕೆ ಮಾಡಿಲ್ಲ',
      'Normal': 'ಸಾಮಾನ್ಯ',
      'Not completed': 'ಪೂರ್ಣಗೊಂಡಿಲ್ಲ',
      'Not now': 'ಈಗಲ್ಲ',
      'Not recorded': 'ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗಿಲ್ಲ',
      'Not recorded in either report': 'ಎರಡೂ ವರದಿಗಳಲ್ಲಿ ದಾಖಲಾಗಿಲ್ಲ',
      'Not set': 'ಹೊಂದಿಸಿಲ್ಲ',
      'Not sure yet': 'ಇನ್ನೂ ಖಚಿತವಿಲ್ಲ.',
      'Notification': 'ಅಧಿಸೂಚನೆ',
      'Notification Settings': 'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳು',
      'Notifications': 'ಅಧಿಸೂಚನೆಗಳು',
      'NotoSansDevanagari': 'ನೋಟೊಸಾನ್ಸ್ ದೇವನಾಗರಿ',
      'NotoSansKannada': 'ನೋಟೊಸಾನ್ಸ್ ಕನ್ನಡ',
      'Nov': 'ನವೆಂಬರ್',
      'Numeric Digit': 'ಸಂಖ್ಯಾತ್ಮಕ ಅಂಕಿ',
      'Nutri': 'ನ್ಯೂಟ್ರಿ',
      'Nutrition': 'ಪೋಷಣೆ',
      'Nutrition Plan': 'ಪೌಷ್ಟಿಕಾಂಶ ಯೋಜನೆ',
      'Nutrition trend graphs are not supported by the backend yet.':
          'ಪೌಷ್ಟಿಕಾಂಶದ ಪ್ರವೃತ್ತಿ ಗ್ರಾಫ್‌ಗಳು ಇನ್ನೂ ಬ್ಯಾಕೆಂಡ್‌ನಿಂದ ಬೆಂಬಲಿತವಾಗಿಲ್ಲ.',
      'OCR TRANSCRIPT': 'OCR ಲಿಪ್ಯಂತರ',
      'OK': 'ಸರಿ',
      'OR CONTINUE WITH': 'ಅಥವಾ ಮುಂದುವರಿಸಿ',
      'OR SIGN UP WITH': 'ಅಥವಾ ಸೈನ್ ಅಪ್ ಮಾಡಿ',
      'ORGANIZATION': 'ಸಂಘಟನೆ',
      'OTP sent to email': 'ಇಮೇಲ್‌ಗೆ OTP ಕಳುಹಿಸಲಾಗಿದೆ',
      'Obese': 'ಬೊಜ್ಜು',
      'Oct': 'ಅಕ್ಟೋಬರ್',
      'Okay': 'ಸರಿ',
      'Older report': 'ಹಳೆಯ ವರದಿ',
      'Onboarding Data': 'ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಡೇಟಾ',
      'Open Camera': 'ಕ್ಯಾಮೆರಾ ತೆರೆಯಿರಿ',
      'Open Fitness Coach': 'ಫಿಟ್‌ನೆಸ್ ತರಬೇತುದಾರರನ್ನು ತೆರೆಯಿರಿ',
      'Open Google Fit app on your device':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ Google Fit ಅಪ್ಲಿಕೇಶನ್ ತೆರೆಯಿರಿ',
      'Open Settings': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ',
      'Open Settings (Gear Icon)': 'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ (ಗೇರ್ ಐಕಾನ್)',
      'Open checkout': 'ಚೆಕ್ಔಟ್ ತೆರೆಯಿರಿ',
      'Open today': 'ಇಂದು ತೆರೆದಿರುತ್ತದೆ',
      'Open tracker': 'ಟ್ರ್ಯಾಕರ್ ತೆರೆಯಿರಿ',
      'Optimize. Sync. Thrive.': 'ಆಪ್ಟಿಮೈಜ್ ಮಾಡಿ. ಸಿಂಕ್ ಮಾಡಿ. ವರ್ಧಿಸಿ.',
      'Optional': 'ಐಚ್ಛಿಕ',
      'Or sign in with a code instead':
          'ಅಥವಾ ಬದಲಿಗೆ ಕೋಡ್‌ನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'Organization': 'ಸಂಸ್ಥೆ',
      'Other': 'ಇತರೆ',
      'Outdoor': 'ಹೊರಾಂಗಣ',
      'Overall experience': 'ಒಟ್ಟಾರೆ ಅನುಭವ',
      'Overview': 'ಅವಲೋಕನ',
      'Overweight': 'ಅಧಿಕ ತೂಕ',
      'Owns your program and clinical review':
          'ನಿಮ್ಮ ಕಾರ್ಯಕ್ರಮ ಮತ್ತು ಕ್ಲಿನಿಕಲ್ ವಿಮರ್ಶೆಯನ್ನು ಹೊಂದಿದೆ',
      'PASSWORD': 'ಪಾಸ್‌ವರ್ಡ್',
      'PASSWORD ADVISOR': 'ಪಾಸ್‌ವರ್ಡ್ ಸಲಹೆಗಾರ',
      'PATCH': 'ಪ್ಯಾಚ್',
      'PDF document': 'PDF ಡಾಕ್ಯುಮೆಂಟ್',
      'PDF import': 'PDF ಆಮದು',
      'PDF ready. Choose Save to Files or share it.':
          'PDF ಸಿದ್ಧವಾಗಿದೆ. ಫೈಲ್‌ಗಳಿಗೆ ಉಳಿಸು ಆಯ್ಕೆಮಾಡಿ ಅಥವಾ ಅದನ್ನು ಹಂಚಿಕೊಳ್ಳಿ.',
      'PERSONAL DETAILS': 'ವೈಯಕ್ತಿಕ ವಿವರಗಳು',
      'PLAN TIMELINE': 'ಯೋಜನೆ ಟೈಮ್‌ಲೈನ್',
      'POST': 'ಪೋಸ್ಟ್',
      'PREFERENCES': 'ಆದ್ಯತೆಗಳು',
      'PREVIOUS': 'ಹಿಂದಿನದು',
      'PUT': 'ಹಾಕಿ',
      'Pain note (optional)': 'ನೋವಿನ ಸೂಚನೆ (ಐಚ್ಛಿಕ)',
      'Password must be at least 6 characters.':
          'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 6 ಅಕ್ಷರಗಳನ್ನು ಹೊಂದಿರಬೇಕು.',
      'Password must be at least 8 characters':
          'ಪಾಸ್‌ವರ್ಡ್ ಕನಿಷ್ಠ 8 ಅಕ್ಷರಗಳನ್ನು ಹೊಂದಿರಬೇಕು.',
      'Password reset successful': 'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸುವಿಕೆ ಯಶಸ್ವಿಯಾಗಿದೆ.',
      'Pause': 'ವಿರಾಮಗೊಳಿಸಿ',
      'Paused and future days are excluded from expected totals.':
          'ನಿರೀಕ್ಷಿತ ಮೊತ್ತಗಳಿಂದ ವಿರಾಮಗೊಳಿಸಲಾದ ಮತ್ತು ಭವಿಷ್ಯದ ದಿನಗಳನ್ನು ಹೊರಗಿಡಲಾಗುತ್ತದೆ.',
      'Pending': 'ಬಾಕಿ ಉಳಿದಿದೆ',
      'People notified when you trigger SOS':
          'ನೀವು SOS ಅನ್ನು ಪ್ರಚೋದಿಸಿದಾಗ ಜನರಿಗೆ ಸೂಚಿಸಲಾಗುತ್ತದೆ',
      'Percentage fat': 'ಕೊಬ್ಬಿನ ಶೇಕಡಾವಾರು',
      'Period: day · week · month': 'ಅವಧಿ: ದಿನ · ವಾರ · ತಿಂಗಳು',
      'Permissions & Reminders': 'ಅನುಮತಿಗಳು ಮತ್ತು ಜ್ಞಾಪನೆಗಳು',
      'Permissions Granted': 'ಅನುಮತಿಗಳನ್ನು ನೀಡಲಾಗಿದೆ',
      'Permissions Required': 'ಅನುಮತಿಗಳು ಅಗತ್ಯವಿದೆ',
      'Personal health advisor': 'ವೈಯಕ್ತಿಕ ಆರೋಗ್ಯ ಸಲಹೆಗಾರ',
      'Personalized advice from your AI Wellness Buddy':
          'ನಿಮ್ಮ AI ವೆಲ್ನೆಸ್ ಸ್ನೇಹಿತರಿಂದ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಸಲಹೆ',
      'Personalizing Experience': 'ಅನುಭವವನ್ನು ವೈಯಕ್ತೀಕರಿಸುವುದು',
      'Phone number': 'ದೂರವಾಣಿ ಸಂಖ್ಯೆ',
      'Photo unavailable': 'ಫೋಟೋ ಲಭ್ಯವಿಲ್ಲ.',
      'Physical job or professional athlete training daily.':
          'ದೈನಂದಿನ ದೈಹಿಕ ಕೆಲಸ ಅಥವಾ ವೃತ್ತಿಪರ ಕ್ರೀಡಾಪಟು ತರಬೇತಿ.',
      'Physician completion summary': 'ವೈದ್ಯರ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಸಾರಾಂಶ',
      'Pilates': 'ಪೈಲೇಟ್ಸ್',
      'Plan details': 'ಯೋಜನೆಯ ವಿವರಗಳು',
      'Plan focus': 'ಯೋಜನೆಯ ಮೇಲೆ ಗಮನ ಹರಿಸಿ',
      'Plan summary': 'ಯೋಜನೆಯ ಸಾರಾಂಶ',
      'Play': 'ಪ್ಲೇ ಮಾಡಿ',
      'Please add the food and quantity you ate.':
          'ದಯವಿಟ್ಟು ನೀವು ಸೇವಿಸಿದ ಆಹಾರ ಮತ್ತು ಪ್ರಮಾಣವನ್ನು ಸೇರಿಸಿ.',
      'Please agree to the Terms of Service & Privacy Policy':
          'ದಯವಿಟ್ಟು ಸೇವಾ ನಿಯಮಗಳು ಮತ್ತು ಗೌಪ್ಯತಾ ನೀತಿಯನ್ನು ಒಪ್ಪಿಕೊಳ್ಳಿ.',
      'Please agree to the required consents and sign your name':
          'ದಯವಿಟ್ಟು ಅಗತ್ಯವಿರುವ ಒಪ್ಪಿಗೆಗಳನ್ನು ಒಪ್ಪಿಕೊಳ್ಳಿ ಮತ್ತು ನಿಮ್ಮ ಹೆಸರಿಗೆ ಸಹಿ ಮಾಡಿ.',
      'Please choose your organization.':
          'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಸಂಸ್ಥೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Please describe what you ate and how much.':
          'ದಯವಿಟ್ಟು ನೀವು ಏನು ತಿಂದಿದ್ದೀರಿ ಮತ್ತು ಎಷ್ಟು ತಿಂದಿದ್ದೀರಿ ಎಂಬುದನ್ನು ವಿವರಿಸಿ.',
      'Please enter a password': 'ದಯವಿಟ್ಟು ಪಾಸ್‌ವರ್ಡ್ ನಮೂದಿಸಿ.',
      'Please enter a valid email': 'ದಯವಿಟ್ಟು ಮಾನ್ಯ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ.',
      'Please enter a valid email address.':
          'ದಯವಿಟ್ಟು ಸರಿಯಾದ ಇಮೇಲ್ ವಿಳಾಸವನ್ನು ನಮೂದಿಸಿ.',
      'Please enter a valid number': 'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಸಂಖ್ಯೆಯನ್ನು ನಮೂದಿಸಿ.',
      'Please enter a valid volume amount':
          'ದಯವಿಟ್ಟು ಮಾನ್ಯವಾದ ಪರಿಮಾಣದ ಮೊತ್ತವನ್ನು ನಮೂದಿಸಿ.',
      'Please enter the 6-digit OTP code.':
          'ದಯವಿಟ್ಟು 6-ಅಂಕಿಯ OTP ಕೋಡ್ ನಮೂದಿಸಿ.',
      'Please enter the 6-digit code.': 'ದಯವಿಟ್ಟು 6-ಅಂಕಿಯ ಕೋಡ್ ಅನ್ನು ನಮೂದಿಸಿ.',
      'Please enter your full name': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರನ್ನು ನಮೂದಿಸಿ.',
      'Please enter your height': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಎತ್ತರವನ್ನು ನಮೂದಿಸಿ.',
      'Please enter your name': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಹೆಸರನ್ನು ನಮೂದಿಸಿ',
      'Please enter your password': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಗುಪ್ತಪದವನ್ನು ನಮೂದಿಸಿ.',
      'Please enter your weight': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ತೂಕವನ್ನು ನಮೂದಿಸಿ.',
      'Please select a condition or check the box below':
          'ದಯವಿಟ್ಟು ಸ್ಥಿತಿಯನ್ನು ಆಯ್ಕೆಮಾಡಿ ಅಥವಾ ಕೆಳಗಿನ ಪೆಟ್ಟಿಗೆಯನ್ನು ಪರಿಶೀಲಿಸಿ.',
      'Please select your company and home facility':
          'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಕಂಪನಿ ಮತ್ತು ಮನೆ ಸೌಲಭ್ಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Please select your date of birth':
          'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಜನ್ಮ ದಿನಾಂಕವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Please select your gender': 'ದಯವಿಟ್ಟು ನಿಮ್ಮ ಲಿಂಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Please take the report photo again.':
          'ದಯವಿಟ್ಟು ವರದಿಯ ಫೋಟೋವನ್ನು ಮತ್ತೊಮ್ಮೆ ತೆಗೆದುಕೊಳ್ಳಿ.',
      'Please try again in a moment.':
          'ದಯವಿಟ್ಟು ಸ್ವಲ್ಪ ಸಮಯದ ನಂತರ ಮತ್ತೊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.',
      'Police': 'ಪೊಲೀಸ್',
      'Preferred cuisine (optional)': 'ಆದ್ಯತೆಯ ತಿನಿಸು (ಐಚ್ಛಿಕ)',
      'Preparing': 'ತಯಾರಿ ನಡೆಸುತ್ತಿದೆ',
      'Preparing instant check-in': 'ತ್ವರಿತ ಚೆಕ್-ಇನ್ ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ',
      'Preparing your personalized dashboard...':
          'ನಿಮ್ಮ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ...',
      'Preview': 'ಪೂರ್ವವೀಕ್ಷಣೆ',
      'Previous bookings': 'ಹಿಂದಿನ ಬುಕಿಂಗ್‌ಗಳು',
      'Previous page': 'ಹಿಂದಿನ ಪುಟ',
      'Previous step': 'ಹಿಂದಿನ ಹಂತ',
      'Previously visited': 'ಹಿಂದೆ ಭೇಟಿ ನೀಡಿದ್ದು',
      'Primary Health Goals': 'ಪ್ರಾಥಮಿಕ ಆರೋಗ್ಯ ಗುರಿಗಳು',
      'Privacy Policy': 'ಗೌಪ್ಯತಾ ನೀತಿ',
      'Profile': 'ಪ್ರೊಫೈಲ್',
      'Profile updated successfully': 'ಪ್ರೊಫೈಲ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ನವೀಕರಿಸಲಾಗಿದೆ',
      'Program history': 'ಕಾರ್ಯಕ್ರಮದ ಇತಿಹಾಸ',
      'Program objectives': 'ಕಾರ್ಯಕ್ರಮದ ಉದ್ದೇಶಗಳು',
      'Program paused': 'ಕಾರ್ಯಕ್ರಮ ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ',
      'Program time elapsed': 'ಕಾರ್ಯಕ್ರಮದ ಸಮಯ ಮುಗಿದಿದೆ',
      'Program timeline': 'ಕಾರ್ಯಕ್ರಮದ ಕಾಲಾನುಕ್ರಮ',
      'Progress': 'ಪ್ರಗತಿ',
      'Progress & Trends': 'ಪ್ರಗತಿ ಮತ್ತು ಪ್ರವೃತ್ತಿಗಳು',
      'Progress report': 'ಪ್ರಗತಿ ವರದಿ',
      'Progress timeline': 'ಪ್ರಗತಿಯ ಕಾಲರೇಖೆ',
      'Progress: 5/7 days completed': 'ಪ್ರಗತಿ: 5/7 ದಿನಗಳು ಪೂರ್ಣಗೊಂಡಿವೆ',
      'Protein': 'ಪ್ರೋಟೀನ್',
      'Provide Explicit Consent': 'ಸ್ಪಷ್ಟ ಸಮ್ಮತಿಯನ್ನು ಒದಗಿಸಿ',
      'Provider': 'ಒದಗಿಸುವವರು',
      'Provider:': 'ಪೂರೈಕೆದಾರ:',
      'Published care-team guidance': 'ಪ್ರಕಟಿತ ಆರೈಕೆ ತಂಡದ ಮಾರ್ಗದರ್ಶನ',
      'Published guidance': 'ಪ್ರಕಟಿತ ಮಾರ್ಗದರ್ಶನ',
      'Pulse Rate': 'ನಾಡಿಮಿಡಿತದ ದರ',
      'QR scan': 'QR ಸ್ಕ್ಯಾನ್',
      'QUICK ACCESS': 'ತ್ವರಿತ ಪ್ರವೇಶ',
      'Quadriceps': 'ಕ್ವಾಡ್ರೈಸ್ಪ್ಸ್',
      'Quest Diagnostics': 'ಕ್ವೆಸ್ಟ್ ಡಯಾಗ್ನೋಸ್ಟಿಕ್ಸ್',
      'Quick Logging': 'ತ್ವರಿತ ಲಾಗಿಂಗ್',
      'Quick start': 'ತ್ವರಿತ ಆರಂಭ',
      'REST': 'ವಿಶ್ರಾಂತಿ',
      'REVIEW DUE': 'ಪರಿಶೀಲನೆ ಕಾರಣ',
      'REWARDS & CHALLENGES': 'ಬಹುಮಾನಗಳು ಮತ್ತು ಸವಾಲುಗಳು',
      'Raise booking issue': 'ಬುಕಿಂಗ್ ಸಮಸ್ಯೆಯನ್ನು ತಿಳಿಸಿ',
      'Rate later': 'ನಂತರ ರೇಟ್ ಮಾಡಿ',
      'Rate limit hit during fallback fetch. Returning cached HealthData.':
          'ಫಾಲ್‌ಬ್ಯಾಕ್ ಪಡೆಯುವಿಕೆಯ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ ಹೆಲ್ತ್‌ಡೇಟಾವನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Rate limit hit during sleep fetch. Returning cached HealthData.':
          'ನಿದ್ರೆ ಪಡೆಯುವ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ HealthData ಅನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Rate limit hit during steps fetch. Returning cached HealthData.':
          'ಹಂತಗಳನ್ನು ಪಡೆಯುವ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ HealthData ಅನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Rate limit or quota hit during batch fetch. Returning cached HealthData.':
          'ಬ್ಯಾಚ್ ಪಡೆಯುವ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ಅಥವಾ ಕೋಟಾ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ HealthData ಅನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Rate limit or quota hit during daily records batch. Returning cached list.':
          'ದೈನಂದಿನ ದಾಖಲೆಗಳ ಬ್ಯಾಚ್ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ಅಥವಾ ಕೋಟಾ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ ಪಟ್ಟಿಯನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Rate limit or quota hit during today-only fetch. Returning cached records.':
          'ಇಂದು ಮಾತ್ರ ಪಡೆಯುವ ಸಮಯದಲ್ಲಿ ದರ ಮಿತಿ ಅಥವಾ ಕೋಟಾ ತಲುಪಿದೆ. ಕ್ಯಾಶ್ ಮಾಡಿದ ದಾಖಲೆಗಳನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Raw JSON': 'ಕಚ್ಚಾ JSON',
      'Read a PDF up to 10 MB and five pages.':
          '10 MB ಮತ್ತು ಐದು ಪುಟಗಳವರೆಗಿನ PDF ಅನ್ನು ಓದಿ.',
      'Reading your report securely on this device':
          'ಈ ಸಾಧನದಲ್ಲಿ ನಿಮ್ಮ ವರದಿಯನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಓದಲಾಗುತ್ತಿದೆ',
      'Ready': 'ಸಿದ್ಧವಾಗಿದೆ',
      'Ready for your next rep': 'ನಿಮ್ಮ ಮುಂದಿನ ಪ್ರತಿನಿಧಿಗೆ ಸಿದ್ಧರಾಗಿ',
      'Realtime reading': 'ನೈಜ-ಸಮಯದ ಓದುವಿಕೆ',
      'Reason': 'ಕಾರಣ',
      'Reason (optional)': 'ಕಾರಣ (ಐಚ್ಛಿಕ)',
      'Receive a summary of today\'s health metrics.':
          'ಇಂದಿನ ಆರೋಗ್ಯ ಮಾಪನಗಳ ಸಾರಾಂಶವನ್ನು ಸ್ವೀಕರಿಸಿ.',
      'Receive personalized tips, metrics summary, and recommendations designed exactly for you.':
          'ನಿಮಗಾಗಿಯೇ ವಿನ್ಯಾಸಗೊಳಿಸಲಾದ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಸಲಹೆಗಳು, ಮೆಟ್ರಿಕ್ಸ್ ಸಾರಾಂಶ ಮತ್ತು ಶಿಫಾರಸುಗಳನ್ನು ಸ್ವೀಕರಿಸಿ.',
      'Recent activity': 'ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ',
      'Recent check-ins': 'ಇತ್ತೀಚಿನ ಚೆಕ್-ಇನ್‌ಗಳು',
      'Recommended': 'ಶಿಫಾರಸು ಮಾಡಲಾಗಿದೆ',
      'Recorded in one report only': 'ಒಂದೇ ವರದಿಯಲ್ಲಿ ದಾಖಲಿಸಲಾಗಿದೆ',
      'Recorded only in the earlier report': 'ಹಿಂದಿನ ವರದಿಯಲ್ಲಿ ಮಾತ್ರ ದಾಖಲಾಗಿದೆ',
      'Recorded only in the latest report':
          'ಇತ್ತೀಚಿನ ವರದಿಯಲ್ಲಿ ಮಾತ್ರ ದಾಖಲಾಗಿದೆ',
      'Recovery and rest.': 'ಚೇತರಿಕೆ ಮತ್ತು ವಿಶ್ರಾಂತಿ.',
      'Recovery note': 'ಮರುಪ್ರಾಪ್ತಿ ಟಿಪ್ಪಣಿ',
      'Refresh': 'ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Refresh check-in history': 'ಚೆಕ್-ಇನ್ ಇತಿಹಾಸವನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Refresh graph': 'ಗ್ರಾಫ್ ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Refresh library': 'ಲೈಬ್ರರಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Reject': 'ತಿರಸ್ಕರಿಸಿ',
      'Remind you to log water and reach your goals.':
          'ನೀರನ್ನು ಲಾಗ್ ಮಾಡಲು ಮತ್ತು ನಿಮ್ಮ ಗುರಿಗಳನ್ನು ತಲುಪಲು ನಿಮಗೆ ನೆನಪಿಸಿ.',
      'Reminders to log and meet your daily water goal':
          '* ನಿಮ್ಮ ದೈನಂದಿನ ನೀರಿನ ಗುರಿಯನ್ನು ಲಾಗ್ ಮಾಡಲು ಮತ್ತು ಪೂರೈಸಲು ಜ್ಞಾಪನೆಗಳು',
      'Remove': 'ತೆಗೆದುಹಾಕಿ',
      'Remove extra exercise': 'ಹೆಚ್ಚುವರಿ ವ್ಯಾಯಾಮ ತೆಗೆದುಹಾಕಿ',
      'Remove last extra set': 'ಕೊನೆಯ ಹೆಚ್ಚುವರಿ ಸೆಟ್ ತೆಗೆದುಹಾಕಿ',
      'Remove measurement': 'ಅಳತೆಯನ್ನು ತೆಗೆದುಹಾಕಿ',
      'Replay': 'ಮರುಪಂದ್ಯ',
      'Report Comparison': 'ಹೋಲಿಕೆ ವರದಿ ಮಾಡಿ',
      'Report Library': 'ವರದಿ ಗ್ರಂಥಾಲಯ',
      'Report comparison': 'ಹೋಲಿಕೆ ವರದಿ ಮಾಡಿ',
      'Reported BMI': 'ವರದಿಯಾದ BMI',
      'Reported and app-calculated BMI are shown separately so their sources stay clear.':
          'ವರದಿ ಮಾಡಲಾದ ಮತ್ತು ಅಪ್ಲಿಕೇಶನ್-ಲೆಕ್ಕಾಚಾರ ಮಾಡಿದ BMI ಅನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ತೋರಿಸಲಾಗುತ್ತದೆ ಆದ್ದರಿಂದ ಅವುಗಳ ಮೂಲಗಳು ಸ್ಪಷ್ಟವಾಗಿರುತ್ತವೆ.',
      'Reported and app-calculated BMI use different sources and are kept separate.':
          'ವರದಿ ಮಾಡಲಾದ ಮತ್ತು ಅಪ್ಲಿಕೇಶನ್-ಲೆಕ್ಕಾಚಾರ ಮಾಡಿದ BMI ವಿಭಿನ್ನ ಮೂಲಗಳನ್ನು ಬಳಸುತ್ತವೆ ಮತ್ತು ಅವುಗಳನ್ನು ಪ್ರತ್ಯೇಕವಾಗಿ ಇರಿಸಲಾಗುತ್ತದೆ.',
      'Reporting period': 'ವರದಿ ಮಾಡುವ ಅವಧಿ',
      'Reps': 'ಪ್ರತಿನಿಧಿಗಳು',
      'Request a place': 'ಸ್ಥಳವನ್ನು ವಿನಂತಿಸಿ',
      'Request a review': 'ವಿಮರ್ಶೆಯನ್ನು ವಿನಂತಿಸಿ',
      'Request a review to begin a personalized program with clear actions and progress tracking.':
          'ಸ್ಪಷ್ಟ ಕ್ರಮಗಳು ಮತ್ತು ಪ್ರಗತಿ ಟ್ರ್ಯಾಕಿಂಗ್‌ನೊಂದಿಗೆ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಕಾರ್ಯಕ್ರಮವನ್ನು ಪ್ರಾರಂಭಿಸಲು ವಿಮರ್ಶೆಯನ್ನು ವಿನಂತಿಸಿ.',
      'Request approved': 'ವಿನಂತಿಯನ್ನು ಅನುಮೋದಿಸಲಾಗಿದೆ',
      'Request denied': 'ವಿನಂತಿಯನ್ನು ನಿರಾಕರಿಸಲಾಗಿದೆ',
      'Request expired': 'ವಿನಂತಿಯ ಅವಧಿ ಮುಗಿದಿದೆ',
      'Required': 'ಅಗತ್ಯವಿದೆ',
      'Required for doctor clearance': 'ವೈದ್ಯರ ಅನುಮತಿ ಅಗತ್ಯವಿದೆ',
      'Reset': 'ಮರುಹೊಂದಿಸಿ',
      'Reset App?': 'ಅಪ್ಲಿಕೇಶನ್ ಅನ್ನು ಮರುಹೊಂದಿಸುವುದೇ?',
      'Reset Onboarding': 'ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಅನ್ನು ಮರುಹೊಂದಿಸಿ',
      'Reset Password': 'ಪಾಸ್ವರ್ಡ್ ಮರುಹೊಂದಿಸಿ',
      'Reset token not found in response':
          'ಪ್ರತಿಕ್ರಿಯೆಯಲ್ಲಿ ಮರುಹೊಂದಿಸುವ ಟೋಕನ್ ಕಂಡುಬಂದಿಲ್ಲ.',
      'Resistance bands': 'ಪ್ರತಿರೋಧ ಬ್ಯಾಂಡ್‌ಗಳು',
      'Respiratory health and breathing': 'ಉಸಿರಾಟದ ಆರೋಗ್ಯ ಮತ್ತು ಉಸಿರಾಟ',
      'Responsible Physician': 'ಜವಾಬ್ದಾರಿಯುತ ವೈದ್ಯರು',
      'Rest day': 'ವಿಶ್ರಾಂತಿ ದಿನ',
      'Rest day — recover well': 'ವಿಶ್ರಾಂತಿ ದಿನ - ಚೆನ್ನಾಗಿ ಚೇತರಿಸಿಕೊಳ್ಳಿ',
      'Resting Heart': 'ವಿಶ್ರಾಂತಿ ಹೃದಯ',
      'Resting heart rate': 'ವಿಶ್ರಾಂತಿ ಹೃದಯ ಬಡಿತ',
      'Results calculating': 'ಫಲಿತಾಂಶಗಳ ಲೆಕ್ಕಾಚಾರ',
      'Retake': 'ಪುನಃ ತೆಗೆದುಕೊಳ್ಳಿ',
      'Retake Photo': 'ಫೋಟೋ ಪುನಃ ತೆಗೆಯಿರಿ',
      'Retry': 'ಮರುಪ್ರಯತ್ನಿಸಿ',
      'Retrying': 'ಮರುಪ್ರಯತ್ನಿಸಲಾಗುತ್ತಿದೆ',
      'Return to Arcare App and refresh':
          'ಆರ್ಕೇರ್ ಅಪ್ಲಿಕೇಶನ್‌ಗೆ ಹಿಂತಿರುಗಿ ಮತ್ತು ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Returning cached HealthData on general error.':
          'ಸಾಮಾನ್ಯ ದೋಷದ ಮೇಲೆ ಕ್ಯಾಶ್ ಮಾಡಲಾದ ಹೆಲ್ತ್‌ಡೇಟಾವನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Returning cached daily records on full fetch error.':
          'ಪೂರ್ಣ ಪಡೆಯುವ ದೋಷದಿಂದಾಗಿ ಕ್ಯಾಶ್ ಮಾಡಲಾದ ದೈನಂದಿನ ದಾಖಲೆಗಳನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ.',
      'Review': 'ವಿಮರ್ಶೆ',
      'Review completed workouts and download PDFs':
          'ಪೂರ್ಣಗೊಂಡ ಜೀವನಕ್ರಮಗಳನ್ನು ಪರಿಶೀಲಿಸಿ ಮತ್ತು PDF ಗಳನ್ನು ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      'Review date will be confirmed on activation':
          'ಸಕ್ರಿಯಗೊಳಿಸಿದ ನಂತರ ಪರಿಶೀಲನಾ ದಿನಾಂಕವನ್ನು ದೃಢೀಕರಿಸಲಾಗುತ್ತದೆ.',
      'Review due': 'ಪರಿಶೀಲನೆಗೆ ಬಾಕಿ ಇದೆ',
      'Review in progress': 'ಪರಿಶೀಲನೆ ಪ್ರಗತಿಯಲ್ಲಿದೆ',
      'Review program': 'ಕಾರ್ಯಕ್ರಮ ವಿಮರ್ಶೆ',
      'Revoke': 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
      'Revoke Explicit Consent': 'ಸ್ಪಷ್ಟ ಸಮ್ಮತಿಯನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
      'Revoke Medical Consent?': 'ವೈದ್ಯಕೀಯ ಒಪ್ಪಿಗೆಯನ್ನು ರದ್ದುಗೊಳಿಸುವುದೇ?',
      'Rewards & Milestone Announcements':
          'ಬಹುಮಾನಗಳು ಮತ್ತು ಮೈಲಿಗಲ್ಲು ಪ್ರಕಟಣೆಗಳು',
      'Rewards & Offers': 'ಬಹುಮಾನಗಳು ಮತ್ತು ಕೊಡುಗೆಗಳು',
      'Rewards Points': 'ರಿವಾರ್ಡ್ ಪಾಯಿಂಟ್‌ಗಳು',
      'Rewind 10 seconds': '10 ಸೆಕೆಂಡುಗಳು ಹಿಂದಕ್ಕೆ ಸರಿಸಿ',
      'Route in Google Maps': 'Google ನಕ್ಷೆಗಳಲ್ಲಿ ಮಾರ್ಗ',
      'S': 'ಸ',
      'SECURE HIPAA COMPLIANT PORTAL': 'ಸುರಕ್ಷಿತ HIPAA ಕಂಪ್ಲೈಂಟ್ ಪೋರ್ಟಲ್',
      'SECURE, HIPAA COMPLIANT PORTAL': 'ಸುರಕ್ಷಿತ, HIPAA ಕಂಪ್ಲೈಂಟ್ ಪೋರ್ಟಲ್',
      'SESSION DURATION': 'ಅಧಿವೇಶನದ ಅವಧಿ',
      'SLEEP': 'ನಿದ್ರೆ',
      'SOS': 'ಎಸ್‌ಒಎಸ್',
      'SOS Emergency': 'SOS ತುರ್ತು ಪರಿಸ್ಥಿತಿ',
      'SOS Triggered': 'SOS ಪ್ರಚೋದಿಸಲಾಗಿದೆ',
      'SOS alert sent': 'SOS ಎಚ್ಚರಿಕೆ ಕಳುಹಿಸಲಾಗಿದೆ',
      'SSO log in': 'SSO ಲಾಗಿನ್',
      'SSO sign up': 'SSO ಸೈನ್ ಅಪ್ ಮಾಡಿ',
      'STEPS': 'ಹಂತಗಳು',
      'Sat': 'ಶನಿ',
      'Saturday': 'ಶನಿವಾರ',
      'Save': 'ಉಳಿಸಿ',
      'Save Changes': 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ',
      'Save at least two health reports to compare them.':
          'ಅವುಗಳನ್ನು ಹೋಲಿಸಲು ಕನಿಷ್ಠ ಎರಡು ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ಉಳಿಸಿ.',
      'Save changes': 'ಬದಲಾವಣೆಗಳನ್ನು ಉಳಿಸಿ',
      'Save correction': 'ತಿದ್ದುಪಡಿಯನ್ನು ಉಳಿಸಿ',
      'Save type': 'ಪ್ರಕಾರವನ್ನು ಉಳಿಸಿ',
      'Save workout': 'ವ್ಯಾಯಾಮವನ್ನು ಉಳಿಸಿ',
      'Saving…': 'ಉಳಿಸಲಾಗುತ್ತಿದೆ...',
      'Scan & start': 'ಸ್ಕ್ಯಾನ್ ಮಾಡಿ ಮತ್ತು ಪ್ರಾರಂಭಿಸಿ',
      'Scan BMI report': 'BMI ವರದಿಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
      'Scan Report': 'ಸ್ಕ್ಯಾನ್ ವರದಿ',
      'Scan facility QR': 'ಸ್ಕ್ಯಾನ್ ಸೌಲಭ್ಯ QR',
      'Scan granted slot at the facility':
          'ಸೌಲಭ್ಯದಲ್ಲಿ ಸ್ಕ್ಯಾನ್ ಮಂಜೂರು ಮಾಡಿದ ಸ್ಲಾಟ್',
      'Scan the facility QR to begin.':
          'ಪ್ರಾರಂಭಿಸಲು ಸೌಲಭ್ಯದ QR ಅನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ.',
      'Scan your gym BMI or body-composition report.':
          'ನಿಮ್ಮ ಜಿಮ್ BMI ಅಥವಾ ದೇಹ ಸಂಯೋಜನೆ ವರದಿಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿ.',
      'Scheduled': 'ನಿಗದಿಪಡಿಸಲಾಗಿದೆ',
      'Score estimate': 'ಸ್ಕೋರ್ ಅಂದಾಜು',
      'Screenshot import': 'ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಆಮದು',
      'Search Exercise Library': 'ವ್ಯಾಯಾಮ ಗ್ರಂಥಾಲಯವನ್ನು ಹುಡುಕಿ',
      'Search by exercise or topic': 'ವ್ಯಾಯಾಮ ಅಥವಾ ವಿಷಯದ ಮೂಲಕ ಹುಡುಕಿ',
      'Sedentary': 'ಜಡ',
      'Select Gender': 'ಲಿಂಗವನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'Select any conditions that apply to you. This helps us tailor your wellness insights.':
          'ನಿಮಗೆ ಅನ್ವಯವಾಗುವ ಯಾವುದೇ ಷರತ್ತುಗಳನ್ನು ಆಯ್ಕೆಮಾಡಿ. ಇದು ನಿಮ್ಮ ಕ್ಷೇಮ ಒಳನೋಟಗಳನ್ನು ರೂಪಿಸಲು ನಮಗೆ ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      'Select the company that enrolled you and the facility you\'ll check in at.':
          'ನಿಮ್ಮನ್ನು ನೋಂದಾಯಿಸಿದ ಕಂಪನಿ ಮತ್ತು ನೀವು ಪರಿಶೀಲಿಸುವ ಸೌಲಭ್ಯವನ್ನು ಆಯ್ಕೆಮಾಡಿ.',
      'Select your organization': 'ನಿಮ್ಮ ಸಂಸ್ಥೆಯನ್ನು ಆಯ್ಕೆಮಾಡಿ',
      'Selected training areas': 'ಆಯ್ದ ತರಬೇತಿ ಕ್ಷೇತ್ರಗಳು',
      'Send Code': 'ಕೋಡ್ ಕಳುಹಿಸಿ',
      'Send OTP': 'ಒಟಿಪಿ ಕಳುಹಿಸಿ',
      'Send SOS': 'SOS ಕಳುಹಿಸಿ',
      'Sending request…': 'ವಿನಂತಿಯನ್ನು ಕಳುಹಿಸಲಾಗುತ್ತಿದೆ...',
      'Sep': 'ಸೆಪ್ಟೆಂಬರ್',
      'Session summary': 'ಅಧಿವೇಶನ ಸಾರಾಂಶ',
      'Set Wellness Goals 🎯': 'ಸ್ವಾಸ್ಥ್ಯ ಗುರಿಗಳನ್ನು ಹೊಂದಿಸಿ 🎯',
      'Set a calorie target': 'ಕ್ಯಾಲೋರಿ ಗುರಿಯನ್ನು ಹೊಂದಿಸಿ',
      'Set personalized goals, monitor progress daily, and stay inspired to live a healthier life.':
          'ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಗುರಿಗಳನ್ನು ಹೊಂದಿಸಿ, ಪ್ರತಿದಿನ ಪ್ರಗತಿಯನ್ನು ಮೇಲ್ವಿಚಾರಣೆ ಮಾಡಿ ಮತ್ತು ಆರೋಗ್ಯಕರ ಜೀವನವನ್ನು ನಡೆಸಲು ಪ್ರೇರೇಪಿತರಾಗಿರಿ.',
      'Sets': 'ಸೆಟ್‌ಗಳು',
      'Setup Google Fit synchronization':
          'Google ಫಿಟ್ ಸಿಂಕ್ರೊನೈಸೇಶನ್ ಅನ್ನು ಸೆಟಪ್ ಮಾಡಿ',
      'Seven-day schedule': 'ಏಳು ದಿನಗಳ ವೇಳಾಪಟ್ಟಿ',
      'Severe or chronic allergic reactions':
          'ತೀವ್ರ ಅಥವಾ ದೀರ್ಘಕಾಲದ ಅಲರ್ಜಿಯ ಪ್ರತಿಕ್ರಿಯೆಗಳು',
      'Shared with the wellness team': 'ಕ್ಷೇಮ ತಂಡದೊಂದಿಗೆ ಹಂಚಿಕೊಳ್ಳಲಾಗಿದೆ',
      'Sharing is active. Qualifying facility managers can access your member-approved body-composition reports, saved comparisons, and workout results for their own facility only. Raw OCR transcripts, medical records, diagnoses, clinical notes, unrelated vitals, and workouts from other facilities are excluded.':
          'ಹಂಚಿಕೆ ಸಕ್ರಿಯವಾಗಿದೆ. ಅರ್ಹತಾ ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರು ನಿಮ್ಮ ಸದಸ್ಯರಿಂದ ಅನುಮೋದಿತ ದೇಹ-ಸಂಯೋಜನೆ ವರದಿಗಳು, ಉಳಿಸಿದ ಹೋಲಿಕೆಗಳು ಮತ್ತು ತಾಲೀಮು ಫಲಿತಾಂಶಗಳನ್ನು ತಮ್ಮದೇ ಆದ ಸೌಲಭ್ಯಕ್ಕಾಗಿ ಮಾತ್ರ ಪ್ರವೇಶಿಸಬಹುದು. ಕಚ್ಚಾ OCR ಪ್ರತಿಲೇಖನಗಳು, ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು, ರೋಗನಿರ್ಣಯಗಳು, ಕ್ಲಿನಿಕಲ್ ಟಿಪ್ಪಣಿಗಳು, ಸಂಬಂಧವಿಲ್ಲದ ಪ್ರಮುಖ ಅಂಶಗಳು ಮತ್ತು ಇತರ ಸೌಲಭ್ಯಗಳಿಂದ ತಾಲೀಮುಗಳನ್ನು ಹೊರಗಿಡಲಾಗಿದೆ.',
      'Sharing is not active. Booking and check-in cannot continue until you approve the facility workflow disclosure again.':
          'ಹಂಚಿಕೆ ಸಕ್ರಿಯವಾಗಿಲ್ಲ. ಸೌಲಭ್ಯದ ಕಾರ್ಯಪ್ರವಾಹದ ಬಹಿರಂಗಪಡಿಸುವಿಕೆಯನ್ನು ನೀವು ಮತ್ತೊಮ್ಮೆ ಅನುಮೋದಿಸುವವರೆಗೆ ಬುಕಿಂಗ್ ಮತ್ತು ಚೆಕ್-ಇನ್ ಮುಂದುವರಿಯಲು ಸಾಧ್ಯವಿಲ್ಲ.',
      'Short explanation': 'ಸಣ್ಣ ವಿವರಣೆ',
      'Shoulder': 'ಭುಜ',
      'Shoulders': 'ಭುಜಗಳು',
      'Shown separately from participation':
          'ಭಾಗವಹಿಸುವಿಕೆಯಿಂದ ಪ್ರತ್ಯೇಕವಾಗಿ ತೋರಿಸಲಾಗಿದೆ',
      'Sign In': 'ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'Sign In With a Code': 'ಕೋಡ್‌ನೊಂದಿಗೆ ಸೈನ್ ಇನ್ ಮಾಡಿ',
      'Sign Out': 'ಸೈನ್ ಔಟ್ ಮಾಡಿ',
      'Sign Up': 'ಸೈನ್ ಅಪ್',
      'Sign out': 'ಸೈನ್ ಔಟ್ ಮಾಡಿ',
      'Sign out?': 'ಸೈನ್ ಔಟ್ ಮಾಡುವುದೇ?',
      'Sign up with SSO': 'SSO ಜೊತೆ ಸೈನ್ ಅಪ್ ಮಾಡಿ',
      'Sign-in code sent to email': 'ಸೈನ್-ಇನ್ ಕೋಡ್ ಅನ್ನು ಇಮೇಲ್‌ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ',
      'Signing in securely...': 'ಸುರಕ್ಷಿತವಾಗಿ ಸೈನ್ ಇನ್ ಮಾಡಲಾಗುತ್ತಿದೆ...',
      'Simulated Demo Active': 'ಸಿಮ್ಯುಲೇಟೆಡ್ ಡೆಮೊ ಸಕ್ರಿಯವಾಗಿದೆ',
      'Skeletal muscle': 'ಅಸ್ಥಿಪಂಜರದ ಸ್ನಾಯು',
      'Skip for now': 'ಇದೀಗ ಬಿಟ್ಟುಬಿಡಿ',
      'Sleep': 'ನಿದ್ರೆ',
      'Sleep & Body composition': 'ನಿದ್ರೆ ಮತ್ತು ದೇಹದ ಸಂಯೋಜನೆ',
      'Sleep Duration': 'ನಿದ್ರೆಯ ಅವಧಿ',
      'Sleep Duration Goal 🌙': 'ನಿದ್ರೆಯ ಅವಧಿಯ ಗುರಿ 🌙',
      'Sleep Quality': 'ನಿದ್ರೆಯ ಗುಣಮಟ್ಟ',
      'Sleep Schedule': 'ನಿದ್ರೆಯ ವೇಳಾಪಟ್ಟಿ',
      'Sleep Schedule Alerts': 'ನಿದ್ರೆಯ ವೇಳಾಪಟ್ಟಿ ಎಚ್ಚರಿಕೆಗಳು',
      'Slot booked': 'ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲಾಗಿದೆ',
      'SocketException': 'ಸಾಕೆಟ್ ಎಕ್ಸೆಪ್ಶನ್',
      'SpO2 Oxygen': 'SpO2 ಆಮ್ಲಜನಕ',
      'Special Symbol': 'ವಿಶೇಷ ಚಿಹ್ನೆ',
      'Specialist-approved member plan': 'ತಜ್ಞರು ಅನುಮೋದಿಸಿದ ಸದಸ್ಯ ಯೋಜನೆ',
      'Staff and service': 'ಸಿಬ್ಬಂದಿ ಮತ್ತು ಸೇವೆ',
      'Start': 'ಪ್ರಾರಂಭಿಸಿ',
      'Start with a care review': 'ಆರೈಕೆ ವಿಮರ್ಶೆಯೊಂದಿಗೆ ಪ್ರಾರಂಭಿಸಿ',
      'Start your journey to optimized wellness today.':
          'ಅತ್ಯುತ್ತಮವಾದ ಯೋಗಕ್ಷೇಮಕ್ಕೆ ನಿಮ್ಮ ಪ್ರಯಾಣವನ್ನು ಇಂದು ಪ್ರಾರಂಭಿಸಿ.',
      'Starting soon': 'ಶೀಘ್ರದಲ್ಲೇ ಪ್ರಾರಂಭವಾಗಲಿದೆ',
      'Starting today-only merge for daily health records to avoid rate limit':
          'ದರ ಮಿತಿಯನ್ನು ತಪ್ಪಿಸಲು ದೈನಂದಿನ ಆರೋಗ್ಯ ದಾಖಲೆಗಳ ವಿಲೀನ ಇಂದಿನಿಂದ ಮಾತ್ರ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ.',
      'Starts': 'ಪ್ರಾರಂಭವಾಗುತ್ತದೆ',
      'Status': 'ಸ್ಥಿತಿ',
      'Stay hydrated throughout the day': 'ದಿನವಿಡೀ ಹೈಡ್ರೇಟೆಡ್ ಆಗಿರಿ',
      'Stay motivated with smart wellness alerts':
          'ಸ್ಮಾರ್ಟ್ ಕ್ಷೇಮ ಎಚ್ಚರಿಕೆಗಳೊಂದಿಗೆ ಪ್ರೇರೇಪಿತರಾಗಿರಿ',
      'Stay tuned for new events.': 'ಹೊಸ ಕಾರ್ಯಕ್ರಮಗಳಿಗಾಗಿ ಟ್ಯೂನ್ ಮಾಡಿ.',
      'Steps': 'ಹಂತಗಳು',
      'Steps, water, sleep & calorie targets':
          'ಹೆಜ್ಜೆಗಳು, ನೀರು, ನಿದ್ರೆ ಮತ್ತು ಕ್ಯಾಲೋರಿ ಗುರಿಗಳು',
      'Still working out': 'ಇನ್ನೂ ವ್ಯಾಯಾಮ ಮಾಡುತ್ತಿದ್ದೇನೆ',
      'Strength session @ Office Gym': 'ಆಫೀಸ್ ಜಿಮ್‌ನಲ್ಲಿ ಬಲವರ್ಧನೆಯ ವ್ಯಾಯಾಮ',
      'Stress Reduction': 'ಒತ್ತಡ ಕಡಿತ',
      'Stress level': 'ಒತ್ತಡದ ಮಟ್ಟ',
      'Strong Password': 'ಬಲವಾದ ಪಾಸ್‌ವರ್ಡ್',
      'Subcutaneous fat': 'ಚರ್ಮದ ಅಡಿಯಲ್ಲಿರುವ ಕೊಬ್ಬು',
      'Submit Check-in': 'ಚೆಕ್-ಇನ್ ಸಲ್ಲಿಸಿ',
      'Submit anonymously': 'ಅನಾಮಧೇಯವಾಗಿ ಸಲ್ಲಿಸಿ',
      'Submit feedback': 'ಪ್ರತಿಕ್ರಿಯೆ ಸಲ್ಲಿಸಿ',
      'Submit rating': 'ರೇಟಿಂಗ್ ಸಲ್ಲಿಸಿ',
      'Submitted anonymously': 'ಅನಾಮಧೇಯವಾಗಿ ಸಲ್ಲಿಸಲಾಗಿದೆ',
      'Submitted — awaiting medical clearance review':
          'ಸಲ್ಲಿಸಲಾಗಿದೆ — ವೈದ್ಯಕೀಯ ಕ್ಲಿಯರೆನ್ಸ್ ಪರಿಶೀಲನೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ',
      'Success!': 'ಯಶಸ್ಸು!',
      'Suggest a healthy snack': 'ಆರೋಗ್ಯಕರ ತಿಂಡಿಯನ್ನು ಸೂಚಿಸಿ',
      'Sun': 'ಸೂರ್ಯ',
      'Sunday': 'ಭಾನುವಾರ',
      'Sync & Refresh Dashboard':
          'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅನ್ನು ಸಿಂಕ್ ಮಾಡಿ ಮತ್ತು ರಿಫ್ರೆಶ್ ಮಾಡಿ',
      'Sync Guide': 'ಸಿಂಕ್ ಗೈಡ್',
      'Sync Health Records': 'ಆರೋಗ್ಯ ದಾಖಲೆಗಳನ್ನು ಸಿಂಕ್ ಮಾಡಿ',
      'Sync Now': 'ಈಗ ಸಿಂಕ್ ಮಾಡಿ',
      'Sync Your Health Data': 'ನಿಮ್ಮ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಸಿಂಕ್ ಮಾಡಿ',
      'Sync pending': 'ಸಿಂಕ್ ಬಾಕಿ ಇದೆ',
      'Sync your steps, sleep, and heart rate automatically.':
          'ನಿಮ್ಮ ಹೆಜ್ಜೆಗಳು, ನಿದ್ರೆ ಮತ್ತು ಹೃದಯ ಬಡಿತವನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಸಿಂಕ್ ಮಾಡಿ.',
      'Synced device data and your corrections':
          'ಸಿಂಕ್ ಮಾಡಿದ ಸಾಧನ ಡೇಟಾ ಮತ್ತು ನಿಮ್ಮ ತಿದ್ದುಪಡಿಗಳು',
      'Synced securely with explicit consent':
          'ಸ್ಪಷ್ಟ ಒಪ್ಪಿಗೆಯೊಂದಿಗೆ ಸುರಕ್ಷಿತವಾಗಿ ಸಿಂಕ್ ಮಾಡಲಾಗಿದೆ',
      'System': 'ವ್ಯವಸ್ಥೆ',
      'Systolic/Diastolic': 'ಸಿಸ್ಟೊಲಿಕ್/ಡಯಾಸ್ಟೊಲಿಕ್',
      'T': 'ಹ',
      'TODAY': 'ಇಂದು',
      'TODAY\'S PLAN': 'ಇಂದಿನ ಯೋಜನೆ',
      'TODAY\'S PLANS': 'ಇಂದಿನ ಯೋಜನೆಗಳು',
      'TRACKED': 'ಟ್ರ್ಯಾಕ್ ಮಾಡಲಾಗಿದೆ',
      'Tailored feedback on health improvements.':
          'ಆರೋಗ್ಯ ಸುಧಾರಣೆಗಳ ಕುರಿತು ಸೂಕ್ತವಾದ ಪ್ರತಿಕ್ರಿಯೆ.',
      'Tap a target to locate it on the body map.':
          'ದೇಹದ ನಕ್ಷೆಯಲ್ಲಿ ಗುರಿಯನ್ನು ಪತ್ತೆಹಚ್ಚಲು ಅದನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.',
      'Tap anywhere to log water intake':
          'ನೀರಿನ ಸೇವನೆಯನ್ನು ಲಾಗ್ ಮಾಡಲು ಎಲ್ಲಿಯಾದರೂ ಟ್ಯಾಪ್ ಮಾಡಿ',
      'Tap to alert emergency contacts':
          'ತುರ್ತು ಸಂಪರ್ಕಗಳಿಗೆ ಎಚ್ಚರಿಕೆ ನೀಡಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
      'Tap to view step-by-step sync setup':
          'ಹಂತ-ಹಂತದ ಸಿಂಕ್ ಸೆಟಪ್ ವೀಕ್ಷಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
      'Tdap (Tetanus, Diphtheria, Pertussis) Vaccine':
          'ಟಿಡಿಎಪಿ (ಧನುರ್ವಾಯು, ಡಿಫ್ತೀರಿಯಾ, ಪೆರ್ಟುಸಿಸ್) ಲಸಿಕೆ',
      'Tell Us About Yourself': 'ನಿಮ್ಮ ಬಗ್ಗೆ ನಮಗೆ ತಿಳಿಸಿ',
      'Tell me a little more': 'ಸ್ವಲ್ಪ ಹೆಚ್ಚು ಹೇಳಿ.',
      'Tell us about your current lifestyle and what you\'re looking to achieve with Vitality.':
          'ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಜೀವನಶೈಲಿ ಮತ್ತು ವೈಟಾಲಿಟಿಯಿಂದ ನೀವು ಏನನ್ನು ಸಾಧಿಸಲು ಬಯಸುತ್ತೀರಿ ಎಂಬುದರ ಕುರಿತು ನಮಗೆ ತಿಳಿಸಿ.',
      'Tell us what worked well or could improve.':
          'ಯಾವುದು ಚೆನ್ನಾಗಿ ಕೆಲಸ ಮಾಡಿದೆ ಅಥವಾ ಯಾವುದು ಸುಧಾರಿಸಬಹುದು ಎಂದು ನಮಗೆ ತಿಳಿಸಿ.',
      'Temporarily unavailable': 'ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ',
      'Terms of Service': 'ಸೇವಾ ನಿಯಮಗಳು',
      'Text is read securely on this device. You can edit every value before approving and saving it.':
          'ಈ ಸಾಧನದಲ್ಲಿ ಪಠ್ಯವನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಓದಬಹುದು. ಅನುಮೋದಿಸುವ ಮತ್ತು ಉಳಿಸುವ ಮೊದಲು ನೀವು ಪ್ರತಿಯೊಂದು ಮೌಲ್ಯವನ್ನು ಸಂಪಾದಿಸಬಹುದು.',
      'Thanks for sharing how you\'re doing today.':
          'ಇವತ್ತು ನೀವು ಹೇಗಿದ್ದೀರಿ ಎಂದು ಹಂಚಿಕೊಂಡಿದ್ದಕ್ಕಾಗಿ ಧನ್ಯವಾದಗಳು.',
      'Thanks — your facility feedback was submitted.':
          'ಧನ್ಯವಾದಗಳು — ನಿಮ್ಮ ಸೌಲಭ್ಯದ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಸಲ್ಲಿಸಲಾಗಿದೆ.',
      'Thanks — your workout feedback was submitted.':
          'ಧನ್ಯವಾದಗಳು — ನಿಮ್ಮ ವ್ಯಾಯಾಮದ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಸಲ್ಲಿಸಲಾಗಿದೆ.',
      'That PDF has more than five pages. Use a shorter PDF or a screenshot of the report.':
          'ಆ PDF ಐದು ಪುಟಗಳಿಗಿಂತ ಹೆಚ್ಚು ಹೊಂದಿದೆ. ಚಿಕ್ಕ PDF ಅಥವಾ ವರದಿಯ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಬಳಸಿ.',
      'That PDF is larger than 10 MB. Choose a shorter PDF or import a screenshot instead.':
          'ಆ PDF 10 MB ಗಿಂತ ದೊಡ್ಡದಾಗಿದೆ. ಬದಲಿಗೆ ಚಿಕ್ಕ PDF ಅನ್ನು ಆರಿಸಿ ಅಥವಾ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಅನ್ನು ಆಮದು ಮಾಡಿಕೊಳ್ಳಿ.',
      'The completion PDF could not be prepared.':
          'ಪೂರ್ಣಗೊಂಡ PDF ಅನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗಲಿಲ್ಲ.',
      'The facility manager declined this walk-in. Book the suggested empty slot or choose another nearby facility.':
          'ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರು ಈ ವಾಕ್-ಇನ್ ಅನ್ನು ನಿರಾಕರಿಸಿದರು. ಸೂಚಿಸಲಾದ ಖಾಲಿ ಸ್ಲಾಟ್ ಅನ್ನು ಬುಕ್ ಮಾಡಿ ಅಥವಾ ಹತ್ತಿರದ ಇನ್ನೊಂದು ಸೌಲಭ್ಯವನ್ನು ಆರಿಸಿ.',
      'The facility manager granted an extra place. Open the scanner when you arrive.':
          'ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರು ಹೆಚ್ಚುವರಿ ಸ್ಥಳವನ್ನು ನೀಡಿದರು. ನೀವು ಬಂದಾಗ ಸ್ಕ್ಯಾನರ್ ತೆರೆಯಿರಿ.',
      'The facility manager has up to 15 minutes to approve this request.':
          'ಈ ವಿನಂತಿಯನ್ನು ಅನುಮೋದಿಸಲು ಸೌಲಭ್ಯ ವ್ಯವಸ್ಥಾಪಕರಿಗೆ 15 ನಿಮಿಷಗಳವರೆಗೆ ಕಾಲಾವಕಾಶವಿರುತ್ತದೆ.',
      'The granted place is not ready yet. Please refresh your bookings.':
          'ಮಂಜೂರು ಮಾಡಲಾದ ಸ್ಥಳ ಇನ್ನೂ ಸಿದ್ಧವಾಗಿಲ್ಲ. ದಯವಿಟ್ಟು ನಿಮ್ಮ ಬುಕಿಂಗ್‌ಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ.',
      'The offer was declined.': 'ಆಫರ್ ನಿರಾಕರಿಸಲಾಯಿತು.',
      'The progress PDF could not be prepared.':
          'ಪ್ರಗತಿ PDF ಅನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗಲಿಲ್ಲ.',
      'The selected PDF is empty or corrupt. Choose another report.':
          'ಆಯ್ಕೆ ಮಾಡಿದ PDF ಖಾಲಿಯಾಗಿದೆ ಅಥವಾ ದೋಷಪೂರಿತವಾಗಿದೆ. ಇನ್ನೊಂದು ವರದಿಯನ್ನು ಆರಿಸಿ.',
      'The source is not uploaded or retained. Review the extracted values before approving and saving this report.':
          'ಮೂಲವನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲಾಗಿಲ್ಲ ಅಥವಾ ಉಳಿಸಿಕೊಳ್ಳಲಾಗಿಲ್ಲ. ಈ ವರದಿಯನ್ನು ಅನುಮೋದಿಸುವ ಮತ್ತು ಉಳಿಸುವ ಮೊದಲು ಹೊರತೆಗೆಯಲಾದ ಮೌಲ್ಯಗಳನ್ನು ಪರಿಶೀಲಿಸಿ.',
      'The workout timer could not appear outside the app. Your workout remains active; retry while the app is open.':
          'ವ್ಯಾಯಾಮದ ಟೈಮರ್ ಅಪ್ಲಿಕೇಶನ್‌ನ ಹೊರಗೆ ಕಾಣಿಸಿಕೊಳ್ಳಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ನಿಮ್ಮ ವ್ಯಾಯಾಮ ಸಕ್ರಿಯವಾಗಿದೆ; ಅಪ್ಲಿಕೇಶನ್ ತೆರೆದಿರುವಾಗ ಮರುಪ್ರಯತ್ನಿಸಿ.',
      'There are no measurements with values in both reports.':
          'ಎರಡೂ ವರದಿಗಳಲ್ಲಿ ಮೌಲ್ಯಗಳೊಂದಿಗೆ ಯಾವುದೇ ಅಳತೆಗಳಿಲ್ಲ.',
      'These changes affect only your personal summary. They never change facility attendance, your approved plan, reports, rewards, challenges, or staff metrics.':
          'ಈ ಬದಲಾವಣೆಗಳು ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಸಾರಾಂಶವನ್ನು ಮಾತ್ರ ಪರಿಣಾಮ ಬೀರುತ್ತವೆ. ಅವು ಸೌಲಭ್ಯ ಹಾಜರಾತಿ, ನಿಮ್ಮ ಅನುಮೋದಿತ ಯೋಜನೆ, ವರದಿಗಳು, ಪ್ರತಿಫಲಗಳು, ಸವಾಲುಗಳು ಅಥವಾ ಸಿಬ್ಬಂದಿ ಮೆಟ್ರಿಕ್‌ಗಳನ್ನು ಎಂದಿಗೂ ಬದಲಾಯಿಸುವುದಿಲ್ಲ.',
      'Thinking...': 'ಯೋಚಿಸುತ್ತಿದ್ದೇನೆ...',
      'This QR belongs to another facility.':
          'ಈ QR ಮತ್ತೊಂದು ಸೌಲಭ್ಯಕ್ಕೆ ಸೇರಿದೆ.',
      'This affects only your personal weekly summary; the official facility session stays unchanged.':
          'ಇದು ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಸಾಪ್ತಾಹಿಕ ಸಾರಾಂಶದ ಮೇಲೆ ಮಾತ್ರ ಪರಿಣಾಮ ಬೀರುತ್ತದೆ; ಅಧಿಕೃತ ಸೌಲಭ್ಯ ಅವಧಿಯು ಬದಲಾಗದೆ ಉಳಿಯುತ್ತದೆ.',
      'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for the member.':
          'ಈ ಹೋಲಿಕೆಯು ದಾಖಲಾದ ಬದಲಾವಣೆಗಳನ್ನು ಮಾತ್ರ ವಿವರಿಸುತ್ತದೆ. ಸದಸ್ಯರಿಗೆ ಯಾವುದು ಆರೋಗ್ಯಕರ ಅಥವಾ ಅನಾರೋಗ್ಯಕರ ಎಂಬುದನ್ನು ಇದು ನಿರ್ಣಯಿಸುವುದಿಲ್ಲ.',
      'This comparison describes recorded changes only. It does not assess what is healthy or unhealthy for you.':
          'ಈ ಹೋಲಿಕೆಯು ದಾಖಲಾದ ಬದಲಾವಣೆಗಳನ್ನು ಮಾತ್ರ ವಿವರಿಸುತ್ತದೆ. ಇದು ನಿಮಗೆ ಯಾವುದು ಆರೋಗ್ಯಕರ ಅಥವಾ ಅನಾರೋಗ್ಯಕರ ಎಂಬುದನ್ನು ನಿರ್ಣಯಿಸುವುದಿಲ್ಲ.',
      'This facility request has expired.': 'ಈ ಸೌಲಭ್ಯ ವಿನಂತಿಯ ಅವಧಿ ಮುಗಿದಿದೆ.',
      'This permanently deletes the report and any comparisons that use it.':
          'ಇದು ವರದಿಯನ್ನು ಮತ್ತು ಅದನ್ನು ಬಳಸುವ ಯಾವುದೇ ಹೋಲಿಕೆಗಳನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುತ್ತದೆ.',
      'This permanently deletes the saved comparison. Your health reports will not be deleted.':
          'ಇದು ಉಳಿಸಿದ ಹೋಲಿಕೆಯನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸುತ್ತದೆ. ನಿಮ್ಮ ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ಅಳಿಸಲಾಗುವುದಿಲ್ಲ.',
      'This replaces only your personal-summary entry. Official attendance remains unchanged.':
          'ಇದು ನಿಮ್ಮ ವೈಯಕ್ತಿಕ-ಸಾರಾಂಶ ನಮೂದನ್ನು ಮಾತ್ರ ಬದಲಾಯಿಸುತ್ತದೆ. ಅಧಿಕೃತ ಹಾಜರಾತಿ ಬದಲಾಗದೆ ಉಳಿಯುತ್ತದೆ.',
      'This report is too long to process. Use a shorter PDF or a clear screenshot of the report.':
          'ಈ ವರದಿಯನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲು ತುಂಬಾ ಉದ್ದವಾಗಿದೆ. ಚಿಕ್ಕ PDF ಅಥವಾ ವರದಿಯ ಸ್ಪಷ್ಟ ಸ್ಕ್ರೀನ್‌ಶಾಟ್ ಬಳಸಿ.',
      'This report separates participation, elapsed time and recorded measurements. It does not make an automated claim of clinical improvement.':
          'ಈ ವರದಿಯು ಭಾಗವಹಿಸುವಿಕೆ, ಕಳೆದ ಸಮಯ ಮತ್ತು ದಾಖಲಾದ ಅಳತೆಗಳನ್ನು ಪ್ರತ್ಯೇಕಿಸುತ್ತದೆ. ಇದು ವೈದ್ಯಕೀಯ ಸುಧಾರಣೆಯ ಸ್ವಯಂಚಾಲಿತ ಹಕ್ಕು ಸಾಧಿಸುವುದಿಲ್ಲ.',
      'This time overlaps another booking':
          'ಈ ಸಮಯವು ಮತ್ತೊಂದು ಬುಕಿಂಗ್ ಅನ್ನು ಅತಿಕ್ರಮಿಸುತ್ತದೆ',
      'This time overlaps another booking. Choose a different hour.':
          'ಈ ಸಮಯವು ಮತ್ತೊಂದು ಬುಕಿಂಗ್ ಅನ್ನು ಅತಿಕ್ರಮಿಸುತ್ತದೆ. ಬೇರೆ ಗಂಟೆಯನ್ನು ಆರಿಸಿ.',
      'This was updated elsewhere. Refresh and review the latest correction.':
          'ಇದನ್ನು ಬೇರೆಡೆ ನವೀಕರಿಸಲಾಗಿದೆ. ಇತ್ತೀಚಿನ ತಿದ್ದುಪಡಿಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಿ ಮತ್ತು ಪರಿಶೀಲಿಸಿ.',
      'This will clear all onboarding and local cache data, returning you to the onboarding wizard. Proceed?':
          'ಇದು ಎಲ್ಲಾ ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಮತ್ತು ಸ್ಥಳೀಯ ಕ್ಯಾಶ್ ಡೇಟಾವನ್ನು ತೆರವುಗೊಳಿಸುತ್ತದೆ, ನಿಮ್ಮನ್ನು ಆನ್‌ಬೋರ್ಡಿಂಗ್ ಮಾಂತ್ರಿಕಕ್ಕೆ ಹಿಂತಿರುಗಿಸುತ್ತದೆ. ಮುಂದುವರಿಯುವುದೇ?',
      'Thu': 'ಗುರು',
      'Thursday': 'ಗುರುವಾರ',
      'Tick assigned sets in order. The next set stays locked until the previous set is done':
          'ನಿಗದಿಪಡಿಸಿದ ಸೆಟ್‌ಗಳನ್ನು ಕ್ರಮವಾಗಿ ಟಿಕ್ ಮಾಡಿ. ಹಿಂದಿನ ಸೆಟ್ ಮುಗಿಯುವವರೆಗೆ ಮುಂದಿನ ಸೆಟ್ ಲಾಕ್ ಆಗಿರುತ್ತದೆ.',
      'Tick each set in order. This exercise ticks itself when every set is done':
          'ಪ್ರತಿಯೊಂದು ಸೆಟ್ ಅನ್ನು ಕ್ರಮವಾಗಿ ಗುರುತಿಸಿ. ಪ್ರತಿಯೊಂದು ಸೆಟ್ ಮುಗಿದ ನಂತರ ಈ ವ್ಯಾಯಾಮವು ತನ್ನನ್ನು ತಾನೇ ಗುರುತಿಸಿಕೊಳ್ಳುತ್ತದೆ.',
      'Tick sets in order. The next set stays locked until the previous set is done.':
          'ಕ್ರಮವಾಗಿ ಟಿಕ್ ಸೆಟ್‌ಗಳು. ಹಿಂದಿನ ಸೆಟ್ ಮುಗಿಯುವವರೆಗೆ ಮುಂದಿನ ಸೆಟ್ ಲಾಕ್ ಆಗಿರುತ್ತದೆ.',
      'Tips for staying hydrated': 'ಹೈಡ್ರೇಟೆಡ್ ಆಗಿರಲು ಸಲಹೆಗಳು',
      'Today': 'ಇಂದು',
      'Today\'s actions': 'ಇಂದಿನ ಕಾರ್ಯಗಳು',
      'Today\'s checklist': 'ಇಂದಿನ ಪರಿಶೀಲನಾಪಟ್ಟಿ',
      'Today\'s exercises work the upper body, core and lower body.':
          'ಇಂದಿನ ವ್ಯಾಯಾಮಗಳು ದೇಹದ ಮೇಲ್ಭಾಗ, ಮಧ್ಯಭಾಗ ಮತ್ತು ಕೆಳಗಿನ ಭಾಗಕ್ಕೆ ವ್ಯಾಯಾಮ ನೀಡುತ್ತವೆ.',
      'Today\'s muscle focus': 'ಇಂದಿನ ಸ್ನಾಯು ಗಮನ',
      'Today\'s workout plan': 'ಇಂದಿನ ವ್ಯಾಯಾಮ ಯೋಜನೆ',
      'Today’s calories and protein': 'ಇಂದಿನ ಕ್ಯಾಲೋರಿಗಳು ಮತ್ತು ಪ್ರೋಟೀನ್',
      'Today’s intake': 'ಇಂದಿನ ಸೇವನೆ',
      'Today’s meals': 'ಇಂದಿನ ಊಟಗಳು',
      'Tomorrow': 'ನಾಳೆ',
      'Total Points': 'ಒಟ್ಟು ಅಂಕಗಳು',
      'Track your daily health, activity, nutrition, and wellness records all in one place.':
          'ನಿಮ್ಮ ದೈನಂದಿನ ಆರೋಗ್ಯ, ಚಟುವಟಿಕೆ, ಪೋಷಣೆ ಮತ್ತು ಕ್ಷೇಮ ದಾಖಲೆಗಳನ್ನು ಒಂದೇ ಸ್ಥಳದಲ್ಲಿ ಟ್ರ್ಯಾಕ್ ಮಾಡಿ.',
      'Tracked': 'ಟ್ರ್ಯಾಕ್ ಮಾಡಲಾಗಿದೆ',
      'Training type': 'ತರಬೇತಿ ಪ್ರಕಾರ',
      'Trains at': 'ರೈಲುಗಳು',
      'Trends Graph': 'ಟ್ರೆಂಡ್‌ಗಳ ಗ್ರಾಫ್',
      'Triceps': 'ಟ್ರೈಸ್ಪ್ಸ್',
      'Trigger SOS?': 'SOS ಅನ್ನು ಪ್ರಚೋದಿಸುವುದೇ?',
      'Try Again': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'Try Demo Mode': 'ಡೆಮೋ ಮೋಡ್ ಪ್ರಯತ್ನಿಸಿ',
      'Try again': 'ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ',
      'Tue': 'ಮಂಗಳ',
      'Tuesday': 'ಮಂಗಳವಾರ',
      'Turn flash off': 'ಫ್ಲ್ಯಾಶ್ ಆಫ್ ಮಾಡಿ',
      'Turn flash on': 'ಫ್ಲ್ಯಾಶ್ ಆನ್ ಮಾಡಿ',
      'Two qualifying readings are needed': 'ಎರಡು ಅರ್ಹತಾ ಓದುವಿಕೆಗಳು ಅಗತ್ಯವಿದೆ.',
      'Type': 'ಪ್ರಕಾರ',
      'Type 1, Type 2, or Prediabetes': 'ಟೈಪ್ 1, ಟೈಪ್ 2, ಅಥವಾ ಪ್ರಿಡಿಯಾಬಿಟಿಸ್',
      'Type your full name as your electronic signature':
          'ನಿಮ್ಮ ಪೂರ್ಣ ಹೆಸರನ್ನು ನಿಮ್ಮ ಎಲೆಕ್ಟ್ರಾನಿಕ್ ಸಹಿಯಾಗಿ ಟೈಪ್ ಮಾಡಿ',
      'U': 'ಸ',
      'Unable to book an available slot':
          'ಲಭ್ಯವಿರುವ ಸ್ಲಾಟ್ ಅನ್ನು ಬುಕ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ.',
      'Unable to load notifications. Pull down to try again.':
          'ಅಧಿಸೂಚನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ. ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಲು ಕೆಳಗೆ ಎಳೆಯಿರಿ.',
      'Unavailable': 'ಲಭ್ಯವಿಲ್ಲ',
      'Unavailable until two qualifying measurements are recorded':
          'ಎರಡು ಅರ್ಹತಾ ಅಳತೆಗಳನ್ನು ದಾಖಲಿಸುವವರೆಗೆ ಲಭ್ಯವಿರುವುದಿಲ್ಲ.',
      'Underweight': 'ಕಡಿಮೆ ತೂಕ',
      'Undo': 'ರದ್ದುಗೊಳಿಸಿ',
      'Unexpected add water log response format':
          'ಅನಿರೀಕ್ಷಿತ ನೀರಿನ ಲಾಗ್ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪವನ್ನು ಸೇರಿಸಿ',
      'Unexpected correction history response':
          'ಅನಿರೀಕ್ಷಿತ ತಿದ್ದುಪಡಿ ಇತಿಹಾಸ ಪ್ರತಿಕ್ರಿಯೆ',
      'Unexpected mood check-in response format':
          'ಅನಿರೀಕ್ಷಿತ ಮನಸ್ಥಿತಿ ಪರಿಶೀಲನೆ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unexpected notifications response format':
          'ಅನಿರೀಕ್ಷಿತ ಅಧಿಸೂಚನೆಗಳ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unexpected nutrition logs response format':
          'ಅನಿರೀಕ್ಷಿತ ಪೌಷ್ಟಿಕಾಂಶ ದಾಖಲೆಗಳ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unexpected update water log response format':
          'ಅನಿರೀಕ್ಷಿತ ನವೀಕರಣ ನೀರಿನ ಲಾಗ್ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unexpected water graph response format':
          'ಅನಿರೀಕ್ಷಿತ ನೀರಿನ ಗ್ರಾಫ್ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unexpected water logs response format':
          'ಅನಿರೀಕ್ಷಿತ ನೀರಿನ ಲಾಗ್‌ಗಳ ಪ್ರತಿಕ್ರಿಯೆ ಸ್ವರೂಪ',
      'Unit': 'ಘಟಕ',
      'Unknown': 'ಅಜ್ಞಾತ',
      'Unknown error': 'ಅಜ್ಞಾತ ದೋಷ',
      'Unlock points, tiers, and exclusive badges':
          'ಪಾಯಿಂಟ್‌ಗಳು, ಶ್ರೇಣಿಗಳು ಮತ್ತು ವಿಶೇಷ ಬ್ಯಾಡ್ಜ್‌ಗಳನ್ನು ಅನ್‌ಲಾಕ್ ಮಾಡಿ.',
      'Upcoming': 'ಮುಂಬರುವ',
      'Update Health': 'ಆರೋಗ್ಯವನ್ನು ನವೀಕರಿಸಿ',
      'Update Your Health': 'ನಿಮ್ಮ ಆರೋಗ್ಯವನ್ನು ನವೀಕರಿಸಿ',
      'Updating': 'ನವೀಕರಿಸಲಾಗುತ್ತಿದೆ',
      'Updating a nutrition log is not supported by the backend yet.':
          'ಪೌಷ್ಟಿಕಾಂಶ ಲಾಗ್ ಅನ್ನು ನವೀಕರಿಸುವುದನ್ನು ಬ್ಯಾಕೆಂಡ್ ಇನ್ನೂ ಬೆಂಬಲಿಸುವುದಿಲ್ಲ.',
      'Updating estimate': 'ಅಂದಾಜನ್ನು ನವೀಕರಿಸಲಾಗುತ್ತಿದೆ',
      'Upper back': 'ಮೇಲಿನ ಬೆನ್ನು',
      'Uppercase Letter': 'ದೊಡ್ಡಕ್ಷರ',
      'Use Photo': 'ಫೋಟೋ ಬಳಸಿ',
      'Use code': 'ಕೋಡ್ ಬಳಸಿ',
      'Use the QR displayed at the facility entrance to begin your workout.':
          'ನಿಮ್ಮ ವ್ಯಾಯಾಮವನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸೌಲಭ್ಯದ ಪ್ರವೇಶದ್ವಾರದಲ್ಲಿ ಪ್ರದರ್ಶಿಸಲಾದ QR ಬಳಸಿ.',
      'Use the camera to scan a gym report.':
          'ಜಿಮ್ ವರದಿಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ಕ್ಯಾಮೆರಾ ಬಳಸಿ.',
      'Use your camera to scan a gym BMI or body-composition report. The photo is read on this device and deleted before upload.':
          'ಜಿಮ್‌ನ BMI ಅಥವಾ ದೇಹ ಸಂಯೋಜನೆ ವರದಿಯನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಲು ನಿಮ್ಮ ಕ್ಯಾಮೆರಾವನ್ನು ಬಳಸಿ. ಫೋಟೋವನ್ನು ಈ ಸಾಧನದಲ್ಲಿ ಓದಲಾಗುತ್ತದೆ ಮತ್ತು ಅಪ್‌ಲೋಡ್ ಮಾಡುವ ಮೊದಲು ಅಳಿಸಲಾಗುತ್ತದೆ.',
      'Use your company work email. We will send a one-time code to finish.':
          'ನಿಮ್ಮ ಕಂಪನಿಯ ಕೆಲಸದ ಇಮೇಲ್ ಬಳಸಿ. ಮುಗಿಸಲು ನಾವು ಒಂದು ಬಾರಿಯ ಕೋಡ್ ಅನ್ನು ಕಳುಹಿಸುತ್ತೇವೆ.',
      'User': 'ಬಳಕೆದಾರ',
      'User email not available': 'ಬಳಕೆದಾರ ಇಮೇಲ್ ಲಭ್ಯವಿಲ್ಲ.',
      'User email not found. Please sign in again.':
          'ಬಳಕೆದಾರರ ಇಮೇಲ್ ಕಂಡುಬಂದಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಿ.',
      'Vaccination': 'ವ್ಯಾಕ್ಸಿನೇಷನ್',
      'Value': 'ಮೌಲ್ಯ',
      'Vegan': 'ಸಸ್ಯಾಹಾರಿ',
      'Vegetarian': 'ಸಸ್ಯಾಹಾರಿ',
      'Verified progress': 'ಪರಿಶೀಲಿಸಿದ ಪ್ರಗತಿ',
      'Verified progress will appear after your activity syncs.':
          'ನಿಮ್ಮ ಚಟುವಟಿಕೆ ಸಿಂಕ್ ಆದ ನಂತರ ಪರಿಶೀಲಿಸಿದ ಪ್ರಗತಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತದೆ.',
      'Verified target reached': 'ಪರಿಶೀಲಿಸಿದ ಗುರಿ ತಲುಪಲಾಗಿದೆ',
      'Verify': 'ಪರಿಶೀಲಿಸಿ',
      'Verify OTP': 'ಒಟಿಪಿ ಪರಿಶೀಲಿಸಿ',
      'Very Active': 'ತುಂಬಾ ಸಕ್ರಿಯ',
      'Very low': 'ತುಂಬಾ ಕಡಿಮೆ',
      'Video is not available.': 'ವೀಡಿಯೊ ಲಭ್ಯವಿಲ್ಲ.',
      'View All': 'ಎಲ್ಲವನ್ನೂ ವೀಕ್ಷಿಸಿ',
      'View Reports': 'ವರದಿಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View completion summary': 'ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಸಾರಾಂಶವನ್ನು ವೀಕ್ಷಿಸಿ',
      'View details': 'ವಿವರಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View hourly slots': 'ಗಂಟೆಯ ಸ್ಲಾಟ್‌ಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View my program': 'ನನ್ನ ಕಾರ್ಯಕ್ರಮವನ್ನು ವೀಕ್ಷಿಸಿ',
      'View other facilities': 'ಇತರ ಸೌಲಭ್ಯಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View pause details': 'ವಿರಾಮ ವಿವರಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View program': 'ಕಾರ್ಯಕ್ರಮ ವೀಕ್ಷಿಸಿ',
      'View request status': 'ವಿನಂತಿಯ ಸ್ಥಿತಿಯನ್ನು ವೀಕ್ಷಿಸಿ',
      'View status': 'ಸ್ಥಿತಿಯನ್ನು ವೀಕ್ಷಿಸಿ',
      'View summary': 'ಸಾರಾಂಶವನ್ನು ವೀಕ್ಷಿಸಿ',
      'View today\'s meals': 'ಇಂದಿನ ಊಟಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'View today\'s session': 'ಇಂದಿನ ಅಧಿವೇಶನವನ್ನು ವೀಕ್ಷಿಸಿ',
      'View tomorrow\'s slots': 'ನಾಳೆಯ ಸ್ಲಾಟ್‌ಗಳನ್ನು ವೀಕ್ಷಿಸಿ',
      'Visceral fat': 'ಒಳಾಂಗಗಳ ಕೊಬ್ಬು',
      'Vitals & Heart': 'ಜೀವಾಧಾರಕಗಳು &amp; ಹೃದಯ',
      'W': 'ವ',
      'W28': 'ಡಬ್ಲ್ಯು 28',
      'WATER ADD LOG': 'ನೀರಿನ ಲಾಗ್ ಸೇರಿಸಿ',
      'WATER DELETE LOG': 'ನೀರು ಅಳಿಸುವಿಕೆ ಲಾಗ್',
      'WATER GRAPH': 'ನೀರಿನ ಗ್ರಾಫ್',
      'WATER LOGS': 'ನೀರಿನ ದಾಖಲೆಗಳು',
      'WATER UPDATE LOG': 'ನೀರಿನ ನವೀಕರಣ ಲಾಗ್',
      'WEIGHT': 'ತೂಕ',
      'WORK EMAIL': 'ಕೆಲಸದ ಇಮೇಲ್',
      'WORKOUT': 'ವ್ಯಾಯಾಮ',
      'WORKOUT DURATION': 'ವ್ಯಾಯಾಮದ ಅವಧಿ',
      'Walk for a few minutes or wait for the data to sync':
          'ಕೆಲವು ನಿಮಿಷಗಳ ಕಾಲ ನಡೆಯಿರಿ ಅಥವಾ ಡೇಟಾ ಸಿಂಕ್ ಆಗುವವರೆಗೆ ಕಾಯಿರಿ',
      'Water': 'ನೀರು',
      'Water Hydration Goal 💧': 'ನೀರಿನ ಜಲಸಂಚಯನ ಗುರಿ 💧',
      'Water Intake': 'ನೀರಿನ ಸೇವನೆ',
      'Water Logs History': 'ನೀರಿನ ದಾಖಲೆಗಳ ಇತಿಹಾಸ',
      'We could not connect to HealthKit. Please try again.':
          'ನಮಗೆ HealthKit ಗೆ ಸಂಪರ್ಕಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'We could not find health measurements in that image. Try a sharper, well-lit photo of the complete report.':
          'ಆ ಚಿತ್ರದಲ್ಲಿ ನಮಗೆ ಆರೋಗ್ಯ ಮಾಪನಗಳು ಸಿಗಲಿಲ್ಲ. ಸಂಪೂರ್ಣ ವರದಿಯ ತೀಕ್ಷ್ಣವಾದ, ಚೆನ್ನಾಗಿ ಬೆಳಗಿದ ಫೋಟೋವನ್ನು ಪ್ರಯತ್ನಿಸಿ.',
      'We could not find health measurements in that screenshot. Choose a clear image of the complete report.':
          'ಆ ಸ್ಕ್ರೀನ್‌ಶಾಟ್‌ನಲ್ಲಿ ನಮಗೆ ಆರೋಗ್ಯ ಮಾಪನಗಳು ಸಿಗಲಿಲ್ಲ. ಸಂಪೂರ್ಣ ವರದಿಯ ಸ್ಪಷ್ಟ ಚಿತ್ರವನ್ನು ಆರಿಸಿ.',
      'We could not open that PDF. It may be encrypted, corrupt, or unsupported.':
          'ನಮಗೆ ಆ PDF ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಅದು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಆಗಿರಬಹುದು, ದೋಷಪೂರಿತವಾಗಿರಬಹುದು ಅಥವಾ ಬೆಂಬಲವಿಲ್ಲದಿರಬಹುದು.',
      'We could not open the camera.': 'ನಮಗೆ ಕ್ಯಾಮೆರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'We could not open the camera. Please try again.':
          'ನಮಗೆ ಕ್ಯಾಮೆರಾ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ದಯವಿಟ್ಟು ಮತ್ತೆ ಪ್ರಯತ್ನಿಸಿ.',
      'We could not read any pages from that PDF. It may be encrypted or corrupt.':
          'ಆ PDF ನಿಂದ ಯಾವುದೇ ಪುಟಗಳನ್ನು ಓದಲು ನಮಗೆ ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಅದು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಆಗಿರಬಹುದು ಅಥವಾ ದೋಷಪೂರಿತವಾಗಿರಬಹುದು.',
      'We could not read that report. Make sure the text is sharp and well lit.':
          'ನಮಗೆ ಆ ವರದಿಯನ್ನು ಓದಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ಪಠ್ಯವು ತೀಕ್ಷ್ಣವಾಗಿದೆ ಮತ್ತು ಚೆನ್ನಾಗಿ ಬೆಳಗಿದೆ ಎಂದು ಖಚಿತಪಡಿಸಿಕೊಳ್ಳಿ.',
      'We could not read the report': 'ನಮಗೆ ವರದಿಯನ್ನು ಓದಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      'We estimate nutrition from the food and portion you describe.':
          'ನೀವು ವಿವರಿಸುವ ಆಹಾರ ಮತ್ತು ಭಾಗದಿಂದ ನಾವು ಪೌಷ್ಟಿಕಾಂಶವನ್ನು ಅಂದಾಜು ಮಾಡುತ್ತೇವೆ.',
      'We process clinical records locally on your device. Access is disabled until you provide explicit authorization.':
          'ನಿಮ್ಮ ಸಾಧನದಲ್ಲಿ ನಾವು ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳನ್ನು ಸ್ಥಳೀಯವಾಗಿ ಪ್ರಕ್ರಿಯೆಗೊಳಿಸುತ್ತೇವೆ. ನೀವು ಸ್ಪಷ್ಟ ದೃಢೀಕರಣವನ್ನು ನೀಡುವವರೆಗೆ ಪ್ರವೇಶವನ್ನು ನಿಷ್ಕ್ರಿಯಗೊಳಿಸಲಾಗುತ್ತದೆ.',
      'We use this data to calculate your personalized wellness scores and recovery goals.':
          'ನಿಮ್ಮ ವೈಯಕ್ತಿಕಗೊಳಿಸಿದ ಕ್ಷೇಮ ಅಂಕಗಳು ಮತ್ತು ಚೇತರಿಕೆ ಗುರಿಗಳನ್ನು ಲೆಕ್ಕಾಚಾರ ಮಾಡಲು ನಾವು ಈ ಡೇಟಾವನ್ನು ಬಳಸುತ್ತೇವೆ.',
      'We will notify you when a Physician has prepared an offer.':
          'ವೈದ್ಯರು ಪ್ರಸ್ತಾಪವನ್ನು ಸಿದ್ಧಪಡಿಸಿದಾಗ ನಾವು ನಿಮಗೆ ತಿಳಿಸುತ್ತೇವೆ.',
      'We\'ll email a one-time code — no password needed.':
          'ನಾವು ಒಂದು ಬಾರಿಯ ಕೋಡ್ ಅನ್ನು ಇಮೇಲ್ ಮಾಡುತ್ತೇವೆ — ಯಾವುದೇ ಪಾಸ್‌ವರ್ಡ್ ಅಗತ್ಯವಿಲ್ಲ.',
      'Weak Security': 'ದುರ್ಬಲ ಭದ್ರತೆ',
      'Wed': 'ಬುಧ',
      'Wednesday': 'ಬುಧವಾರ',
      'Week': 'ವಾರ',
      'Week-by-Week Logs (Last 4 Weeks)':
          'ವಾರದಿಂದ ವಾರದ ದಾಖಲೆಗಳು (ಕಳೆದ 4 ವಾರಗಳು)',
      'Weekly': 'ಸಾಪ್ತಾಹಿಕ',
      'Weekly Average': 'ವಾರದ ಸರಾಸರಿ',
      'Weekly Average Steps': 'ವಾರದ ಸರಾಸರಿ ಹೆಜ್ಜೆಗಳು',
      'Weekly Care Progress': 'ಸಾಪ್ತಾಹಿಕ ಆರೈಕೆ ಪ್ರಗತಿ',
      'Weekly Hydration Champion': 'ವಾರದ ಜಲಸಂಚಯನ ಚಾಂಪಿಯನ್',
      'Weekly logs of total distance and calories.':
          'ಒಟ್ಟು ದೂರ ಮತ್ತು ಕ್ಯಾಲೊರಿಗಳ ಸಾಪ್ತಾಹಿಕ ದಾಖಲೆಗಳು.',
      'Weekly training': 'ಸಾಪ್ತಾಹಿಕ ತರಬೇತಿ',
      'Weekly training is unavailable. Your existing health data is still safe.':
          'ಸಾಪ್ತಾಹಿಕ ತರಬೇತಿ ಲಭ್ಯವಿಲ್ಲ. ನಿಮ್ಮ ಅಸ್ತಿತ್ವದಲ್ಲಿರುವ ಆರೋಗ್ಯ ಡೇಟಾ ಇನ್ನೂ ಸುರಕ್ಷಿತವಾಗಿದೆ.',
      'Weight': 'ತೂಕ',
      'Weight (kg)': 'ತೂಕ (ಕೆಜಿ)',
      'Weight Loss': 'ತೂಕ ಇಳಿಕೆ',
      'Welcome to Your Wellness Journey': 'ನಿಮ್ಮ ಸ್ವಾಸ್ಥ್ಯ ಪ್ರಯಾಣಕ್ಕೆ ಸುಸ್ವಾಗತ',
      'Wellness Goals': 'ಸ್ವಾಸ್ಥ್ಯ ಗುರಿಗಳು',
      'Wellness Score': 'ಸ್ವಾಸ್ಥ್ಯ ಸ್ಕೋರ್',
      'Wellness Sync securely aggregates data from Google Health Connect & Apple HealthKit to populate your activity totals automatically.':
          'ನಿಮ್ಮ ಚಟುವಟಿಕೆಯ ಮೊತ್ತವನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಜನಪ್ರಿಯಗೊಳಿಸಲು ವೆಲ್ನೆಸ್ ಸಿಂಕ್ Google Health Connect ಮತ್ತು Apple HealthKit ನಿಂದ ಡೇಟಾವನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಒಟ್ಟುಗೂಡಿಸುತ್ತದೆ.',
      'Wellness data is synced automatically.':
          'ಸ್ವಾಸ್ಥ್ಯ ಡೇಟಾವನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಸಿಂಕ್ ಮಾಡಲಾಗುತ್ತದೆ.',
      'Where do you feel it?': 'ನಿಮಗೆ ಅದು ಎಲ್ಲಿ ಅನಿಸುತ್ತದೆ?',
      'Wiping medical consent will immediately remove all clinical records, vaccinations, and ECG reports from your view.':
          'ವೈದ್ಯಕೀಯ ಒಪ್ಪಿಗೆಯನ್ನು ಅಳಿಸುವುದರಿಂದ ಎಲ್ಲಾ ಕ್ಲಿನಿಕಲ್ ದಾಖಲೆಗಳು, ವ್ಯಾಕ್ಸಿನೇಷನ್‌ಗಳು ಮತ್ತು ಇಸಿಜಿ ವರದಿಗಳು ನಿಮ್ಮ ದೃಷ್ಟಿಕೋನದಿಂದ ತಕ್ಷಣವೇ ತೆಗೆದುಹಾಕಲ್ಪಡುತ್ತವೆ.',
      'Withdraw': 'ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
      'Withdraw access': 'ಪ್ರವೇಶವನ್ನು ಹಿಂತೆಗೆದುಕೊಳ್ಳಿ',
      'Withdraw from this program': 'ಈ ಕಾರ್ಯಕ್ರಮದಿಂದ ಹಿಂದೆ ಸರಿಯಿರಿ',
      'Withdraw from this program?': 'ಈ ಕಾರ್ಯಕ್ರಮದಿಂದ ಹಿಂದೆ ಸರಿಯುವುದೇ?',
      'Work email verification': 'ಕೆಲಸದ ಇಮೇಲ್ ಪರಿಶೀಲನೆ',
      'Work-email SSO accounts need Apple or Google signed in before Health data can be read from Apple Health or Health Connect.':
          'ಆಪಲ್ ಹೆಲ್ತ್ ಅಥವಾ ಹೆಲ್ತ್ ಕನೆಕ್ಟ್‌ನಿಂದ ಹೆಲ್ತ್ ಡೇಟಾವನ್ನು ಓದುವ ಮೊದಲು ಕೆಲಸದ ಇಮೇಲ್ SSO ಖಾತೆಗಳಿಗೆ ಆಪಲ್ ಅಥವಾ ಗೂಗಲ್ ಸೈನ್ ಇನ್ ಆಗಿರಬೇಕು.',
      'Workout': 'ತಾಲೀಮು',
      'Workout Plan': 'ವ್ಯಾಯಾಮ ಯೋಜನೆ',
      'Workout Reports': 'ವ್ಯಾಯಾಮ ವರದಿಗಳು',
      'Workout check-in code': 'ವ್ಯಾಯಾಮ ಚೆಕ್-ಇನ್ ಕೋಡ್',
      'Workout days this week': 'ಈ ವಾರದ ವ್ಯಾಯಾಮದ ದಿನಗಳು',
      'Workout in progress': 'ವ್ಯಾಯಾಮ ಪ್ರಗತಿಯಲ್ಲಿದೆ',
      'Workout insights': 'ವ್ಯಾಯಾಮದ ಒಳನೋಟಗಳು',
      'Workout progress': 'ವ್ಯಾಯಾಮದ ಪ್ರಗತಿ',
      'Workout quality': 'ವ್ಯಾಯಾಮದ ಗುಣಮಟ್ಟ',
      'Workout report': 'ವ್ಯಾಯಾಮ ವರದಿ',
      'Workout session completed.': 'ವ್ಯಾಯಾಮ ಅವಧಿ ಪೂರ್ಣಗೊಂಡಿದೆ.',
      'Workout started. Your timer is running.':
          'ವ್ಯಾಯಾಮ ಪ್ರಾರಂಭವಾಗಿದೆ. ನಿಮ್ಮ ಟೈಮರ್ ರನ್ ಆಗುತ್ತಿದೆ.',
      'Workout timer unavailable': 'ವರ್ಕ್‌ಔಟ್ ಟೈಮರ್ ಲಭ್ಯವಿಲ್ಲ.',
      'Worse': 'ಕೆಟ್ಟದಾಗಿದೆ',
      'Wrong workout type': 'ತಪ್ಪಾದ ವ್ಯಾಯಾಮದ ಪ್ರಕಾರ',
      'YOUR LAST 7 DAYS': 'ನಿಮ್ಮ ಕೊನೆಯ 7 ದಿನಗಳು',
      'Yes': 'ಹೌದು',
      'Yes, open checkout': 'ಹೌದು, ಚೆಕ್ಔಟ್ ತೆರೆಯಿರಿ',
      'Yesterday': 'ನಿನ್ನೆ',
      'Yoga': 'ಯೋಗ',
      'You are currently leading. The winner is decided after the timeline and sync grace period.':
          'ನೀವು ಪ್ರಸ್ತುತ ಮುನ್ನಡೆಯಲ್ಲಿದ್ದೀರಿ. ಟೈಮ್‌ಲೈನ್ ಮತ್ತು ಸಿಂಕ್ ಗ್ರೇಸ್ ಅವಧಿಯ ನಂತರ ವಿಜೇತರನ್ನು ನಿರ್ಧರಿಸಲಾಗುತ್ತದೆ.',
      'You are up to date for this week.': 'ಈ ವಾರದ ಬಗ್ಗೆ ನಿಮಗೆ ಮಾಹಿತಿ ಇದೆ.',
      'You can sign back in anytime with the same account.':
          'ನೀವು ಅದೇ ಖಾತೆಯೊಂದಿಗೆ ಯಾವುದೇ ಸಮಯದಲ್ಲಿ ಮತ್ತೆ ಸೈನ್ ಇನ್ ಮಾಡಬಹುದು.',
      'You have joined all challenges!': 'ನೀವು ಎಲ್ಲಾ ಸವಾಲುಗಳನ್ನು ಪೂರೈಸಿದ್ದೀರಿ!',
      'You have withdrawn from the program.':
          'ನೀವು ಕಾರ್ಯಕ್ರಮದಿಂದ ಹಿಂದೆ ಸರಿದಿದ್ದೀರಿ.',
      'You will be redirected to the Play Store to download the app.':
          'ಅಪ್ಲಿಕೇಶನ್ ಡೌನ್‌ಲೋಡ್ ಮಾಡಲು ನಿಮ್ಮನ್ನು ಪ್ಲೇ ಸ್ಟೋರ್‌ಗೆ ಮರುನಿರ್ದೇಶಿಸಲಾಗುತ್ತದೆ.',
      'You will need to provide explicit consent again to re-sync them.':
          'ಅವುಗಳನ್ನು ಮರು-ಸಿಂಕ್ ಮಾಡಲು ನೀವು ಮತ್ತೊಮ್ಮೆ ಸ್ಪಷ್ಟ ಸಮ್ಮತಿಯನ್ನು ನೀಡಬೇಕಾಗುತ್ತದೆ.',
      'Your AI Wellness Companion': 'ನಿಮ್ಮ AI ವೆಲ್ನೆಸ್ ಕಂಪ್ಯಾನಿಯನ್',
      'Your Activity Level': 'ನಿಮ್ಮ ಚಟುವಟಿಕೆ ಮಟ್ಟ',
      'Your Employer': 'ನಿಮ್ಮ ಉದ್ಯೋಗದಾತರು',
      'Your Fitness Coach': 'ನಿಮ್ಮ ಫಿಟ್‌ನೆಸ್ ತರಬೇತುದಾರ',
      'Your Rewards': 'ನಿಮ್ಮ ಬಹುಮಾನಗಳು',
      'Your booked slot has ended': 'ನಿಮ್ಮ ಬುಕ್ ಮಾಡಿದ ಸ್ಲಾಟ್ ಕೊನೆಗೊಂಡಿದೆ.',
      'Your care program is complete': 'ನಿಮ್ಮ ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ ಪೂರ್ಣಗೊಂಡಿದೆ.',
      'Your care program is now active.':
          'ನಿಮ್ಮ ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮ ಈಗ ಸಕ್ರಿಯವಾಗಿದೆ.',
      'Your care team': 'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡ',
      'Your care team can recommend a program for you':
          'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡವು ನಿಮಗಾಗಿ ಒಂದು ಕಾರ್ಯಕ್ರಮವನ್ನು ಶಿಫಾರಸು ಮಾಡಬಹುದು.',
      'Your care team can recommend a program for your goals.':
          'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡವು ನಿಮ್ಮ ಗುರಿಗಳಿಗೆ ಸೂಕ್ತವಾದ ಕಾರ್ಯಕ್ರಮವನ್ನು ಶಿಫಾರಸು ಮಾಡಬಹುದು.',
      'Your care team is reviewing the right program for you.':
          'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡವು ನಿಮಗೆ ಸೂಕ್ತವಾದ ಕಾರ್ಯಕ್ರಮವನ್ನು ಪರಿಶೀಲಿಸುತ್ತಿದೆ.',
      'Your care team is reviewing your request':
          'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡವು ನಿಮ್ಮ ವಿನಂತಿಯನ್ನು ಪರಿಶೀಲಿಸುತ್ತಿದೆ.',
      'Your care team will retain the program history. You can request another review later.':
          'ನಿಮ್ಮ ಆರೈಕೆ ತಂಡವು ಕಾರ್ಯಕ್ರಮದ ಇತಿಹಾಸವನ್ನು ಉಳಿಸಿಕೊಳ್ಳುತ್ತದೆ. ನೀವು ನಂತರ ಮತ್ತೊಂದು ವಿಮರ್ಶೆಯನ್ನು ವಿನಂತಿಸಬಹುದು.',
      'Your checklist is saved. Your estimated workout insights are being updated.':
          'ನಿಮ್ಮ ಪರಿಶೀಲನಾಪಟ್ಟಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಅಂದಾಜು ವ್ಯಾಯಾಮದ ಒಳನೋಟಗಳನ್ನು ನವೀಕರಿಸಲಾಗುತ್ತಿದೆ.',
      'Your company specialist uses AI to prepare a plan from the health and preference information you provide. They review the plan before you can see it.':
          'ನೀವು ಒದಗಿಸುವ ಆರೋಗ್ಯ ಮತ್ತು ಆದ್ಯತೆಯ ಮಾಹಿತಿಯಿಂದ ಯೋಜನೆಯನ್ನು ತಯಾರಿಸಲು ನಿಮ್ಮ ಕಂಪನಿ ತಜ್ಞರು AI ಅನ್ನು ಬಳಸುತ್ತಾರೆ. ನೀವು ಅದನ್ನು ನೋಡುವ ಮೊದಲು ಅವರು ಯೋಜನೆಯನ್ನು ಪರಿಶೀಲಿಸುತ್ತಾರೆ.',
      'Your completion summary remains available here.':
          'ನಿಮ್ಮ ಪೂರ್ಣಗೊಳಿಸುವಿಕೆಯ ಸಾರಾಂಶವು ಇಲ್ಲಿ ಲಭ್ಯವಿದೆ.',
      'Your correction changes this member-facing display and preserves the original synced reading.':
          'ನಿಮ್ಮ ತಿದ್ದುಪಡಿಯು ಈ ಸದಸ್ಯ-ಮುಖಿ ಪ್ರದರ್ಶನವನ್ನು ಬದಲಾಯಿಸುತ್ತದೆ ಮತ್ತು ಮೂಲ ಸಿಂಕ್ ಮಾಡಿದ ಓದುವಿಕೆಯನ್ನು ಸಂರಕ್ಷಿಸುತ್ತದೆ.',
      'Your current program continues until you accept this replacement offer.':
          'ನೀವು ಈ ಬದಲಿ ಕೊಡುಗೆಯನ್ನು ಸ್ವೀಕರಿಸುವವರೆಗೆ ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಪ್ರೋಗ್ರಾಂ ಮುಂದುವರಿಯುತ್ತದೆ.',
      'Your enrolment needs a quick medical clearance review by our staff before your dashboard unlocks. We\'ll notify you once it\'s approved.':
          'ನಿಮ್ಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅನ್‌ಲಾಕ್ ಆಗುವ ಮೊದಲು ನಮ್ಮ ಸಿಬ್ಬಂದಿಯಿಂದ ನಿಮ್ಮ ದಾಖಲಾತಿಗೆ ತ್ವರಿತ ವೈದ್ಯಕೀಯ ಕ್ಲಿಯರೆನ್ಸ್ ಪರಿಶೀಲನೆ ಅಗತ್ಯವಿದೆ. ಅದು ಅನುಮೋದನೆ ಪಡೆದ ನಂತರ ನಾವು ನಿಮಗೆ ತಿಳಿಸುತ್ತೇವೆ.',
      'Your estimated workout insights are being prepared. This page refreshes automatically.':
          'ನಿಮ್ಮ ಅಂದಾಜು ವ್ಯಾಯಾಮದ ಒಳನೋಟಗಳನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ. ಈ ಪುಟವು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ರಿಫ್ರೆಶ್ ಆಗುತ್ತದೆ.',
      'Your first check-in will appear here.':
          'ನಿಮ್ಮ ಮೊದಲ ಚೆಕ್-ಇನ್ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.',
      'Your first completed visit helps your organisation understand the facility experience.':
          'ನಿಮ್ಮ ಮೊದಲ ಪೂರ್ಣಗೊಂಡ ಭೇಟಿಯು ನಿಮ್ಮ ಸಂಸ್ಥೆಗೆ ಸೌಲಭ್ಯದ ಅನುಭವವನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      'Your first meal will appear here.': 'ನಿಮ್ಮ ಮೊದಲ ಊಟ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.',
      'Your guidance and history remain available. New daily actions are paused.':
          'ನಿಮ್ಮ ಮಾರ್ಗದರ್ಶನ ಮತ್ತು ಇತಿಹಾಸ ಲಭ್ಯವಿರುತ್ತದೆ. ಹೊಸ ದೈನಂದಿನ ಕ್ರಿಯೆಗಳನ್ನು ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.',
      'Your guidance and progress are saved. New actions are paused.':
          'ನಿಮ್ಮ ಮಾರ್ಗದರ್ಶನ ಮತ್ತು ಪ್ರಗತಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಹೊಸ ಕ್ರಿಯೆಗಳನ್ನು ವಿರಾಮಗೊಳಿಸಲಾಗಿದೆ.',
      'Your health identity & preferences':
          'ನಿಮ್ಮ ಆರೋಗ್ಯ ಗುರುತು ಮತ್ತು ಆದ್ಯತೆಗಳು',
      'Your health report': 'ನಿಮ್ಮ ಆರೋಗ್ಯ ವರದಿ',
      'Your iPhone does not support Live Activities. Your workout remains active and checkout is still available here.':
          'ನಿಮ್ಮ iPhone ಲೈವ್ ಚಟುವಟಿಕೆಗಳನ್ನು ಬೆಂಬಲಿಸುವುದಿಲ್ಲ. ನಿಮ್ಮ ವ್ಯಾಯಾಮವು ಸಕ್ರಿಯವಾಗಿದೆ ಮತ್ತು ಚೆಕ್ಔಟ್ ಇನ್ನೂ ಇಲ್ಲಿ ಲಭ್ಯವಿದೆ.',
      'Your meal': 'ನಿಮ್ಮ ಊಟ',
      'Your medical data is encrypted and only used to personalize your wellness experience. We never share your data with third parties.':
          'ನಿಮ್ಮ ವೈದ್ಯಕೀಯ ಡೇಟಾವನ್ನು ಎನ್‌ಕ್ರಿಪ್ಟ್ ಮಾಡಲಾಗಿದೆ ಮತ್ತು ನಿಮ್ಮ ಕ್ಷೇಮ ಅನುಭವವನ್ನು ವೈಯಕ್ತೀಕರಿಸಲು ಮಾತ್ರ ಬಳಸಲಾಗುತ್ತದೆ. ನಾವು ನಿಮ್ಮ ಡೇಟಾವನ್ನು ಮೂರನೇ ವ್ಯಕ್ತಿಗಳೊಂದಿಗೆ ಎಂದಿಗೂ ಹಂಚಿಕೊಳ್ಳುವುದಿಲ್ಲ.',
      'Your medical files, vaccinations, and lab results are protected under HIPAA/GDPR standards.':
          'ನಿಮ್ಮ ವೈದ್ಯಕೀಯ ಫೈಲ್‌ಗಳು, ವ್ಯಾಕ್ಸಿನೇಷನ್‌ಗಳು ಮತ್ತು ಲ್ಯಾಬ್ ಫಲಿತಾಂಶಗಳನ್ನು HIPAA/GDPR ಮಾನದಂಡಗಳ ಅಡಿಯಲ್ಲಿ ರಕ್ಷಿಸಲಾಗಿದೆ.',
      'Your name is hidden from the wellness team; only trends are shared.':
          'ನಿಮ್ಮ ಹೆಸರನ್ನು ಕ್ಷೇಮ ತಂಡದಿಂದ ಮರೆಮಾಡಲಾಗಿದೆ; ಕೇವಲ ಪ್ರವೃತ್ತಿಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಲಾಗುತ್ತದೆ.',
      'Your objectives': 'ನಿಮ್ಮ ಉದ್ದೇಶಗಳು',
      'Your password has been successfully reset. You can now log in with your new credentials.':
          'ನಿಮ್ಮ ಪಾಸ್‌ವರ್ಡ್ ಅನ್ನು ಯಶಸ್ವಿಯಾಗಿ ಮರುಹೊಂದಿಸಲಾಗಿದೆ. ನೀವು ಈಗ ನಿಮ್ಮ ಹೊಸ ರುಜುವಾತುಗಳೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಬಹುದು.',
      'Your personal check-in history is visible only in your account.':
          'ನಿಮ್ಮ ವೈಯಕ್ತಿಕ ಚೆಕ್-ಇನ್ ಇತಿಹಾಸವು ನಿಮ್ಮ ಖಾತೆಯಲ್ಲಿ ಮಾತ್ರ ಗೋಚರಿಸುತ್ತದೆ.',
      'Your phone is now at least 2 km from the exact place where you scanned into this workout. Open checkout to finish the active session.':
          'ನೀವು ಈ ವ್ಯಾಯಾಮವನ್ನು ಸ್ಕ್ಯಾನ್ ಮಾಡಿದ ಸ್ಥಳದಿಂದ ನಿಮ್ಮ ಫೋನ್ ಈಗ ಕನಿಷ್ಠ 2 ಕಿ.ಮೀ ದೂರದಲ್ಲಿದೆ. ಸಕ್ರಿಯ ಅವಧಿಯನ್ನು ಮುಗಿಸಲು ಚೆಕ್ಔಟ್ ತೆರೆಯಿರಿ.',
      'Your post-workout feedback': 'ವ್ಯಾಯಾಮದ ನಂತರದ ನಿಮ್ಮ ಪ್ರತಿಕ್ರಿಯೆ',
      'Your previous chats will appear here.':
          'ನಿಮ್ಮ ಹಿಂದಿನ ಚಾಟ್‌ಗಳು ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತವೆ.',
      'Your recent visits help your organisation understand how this facility is performing.':
          'ನಿಮ್ಮ ಇತ್ತೀಚಿನ ಭೇಟಿಗಳು ನಿಮ್ಮ ಸಂಸ್ಥೆಯು ಈ ಸೌಲಭ್ಯವು ಹೇಗೆ ಕಾರ್ಯನಿರ್ವಹಿಸುತ್ತಿದೆ ಎಂಬುದನ್ನು ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು ಸಹಾಯ ಮಾಡುತ್ತದೆ.',
      'Your report is saved. Add your height in Profile to calculate app BMI.':
          'ನಿಮ್ಮ ವರದಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ. ಅಪ್ಲಿಕೇಶನ್ BMI ಅನ್ನು ಲೆಕ್ಕಹಾಕಲು ಪ್ರೊಫೈಲ್‌ನಲ್ಲಿ ನಿಮ್ಮ ಎತ್ತರವನ್ನು ಸೇರಿಸಿ.',
      'Your saved care information is still safe.':
          'ನಿಮ್ಮ ಉಳಿಸಿದ ಆರೈಕೆ ಮಾಹಿತಿ ಇನ್ನೂ ಸುರಕ್ಷಿತವಾಗಿದೆ.',
      'Your trend': 'ನಿಮ್ಮ ಪ್ರವೃತ್ತಿ',
      'Your workout facts are safely saved. The AI estimate is temporarily unavailable.':
          'ನಿಮ್ಮ ವ್ಯಾಯಾಮದ ಸಂಗತಿಗಳನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಉಳಿಸಲಾಗಿದೆ. AI ಅಂದಾಜು ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ.',
      'Your workout facts are safely saved. We will retry the AI estimate automatically.':
          'ನಿಮ್ಮ ವ್ಯಾಯಾಮದ ಸಂಗತಿಗಳನ್ನು ಸುರಕ್ಷಿತವಾಗಿ ಉಳಿಸಲಾಗಿದೆ. ನಾವು AI ಅಂದಾಜನ್ನು ಸ್ವಯಂಚಾಲಿತವಾಗಿ ಮರುಪ್ರಯತ್ನಿಸುತ್ತೇವೆ.',
      'Your workout report is ready to review.':
          'ನಿಮ್ಮ ವ್ಯಾಯಾಮ ವರದಿ ಪರಿಶೀಲಿಸಲು ಸಿದ್ಧವಾಗಿದೆ.',
      'Zumba': 'ಜುಂಬಾ',
      'abdomen and midsection': 'ಹೊಟ್ಟೆ ಮತ್ತು ಮಧ್ಯಭಾಗ',
      'accept this suggested slot': 'ಈ ಸೂಚಿಸಲಾದ ಸ್ಲಾಟ್ ಅನ್ನು ಸ್ವೀಕರಿಸಿ',
      'activeCalories': 'ಸಕ್ರಿಯ ಕ್ಯಾಲೋರಿಗಳು',
      'alex@company.com': 'ಅಲೆಕ್ಸ್@ಕಂಪನಿ.ಕಾಮ್',
      'alex@vitality.pro': 'alex@vitality.pro',
      'alex@vitalitypro.com': 'alex@vitalitypro.com',
      'already have a booking': 'ಈಗಾಗಲೇ ಬುಕಿಂಗ್ ಇದೆ.',
      'already have the booking': 'ಈಗಾಗಲೇ ಬುಕಿಂಗ್ ಆಗಿದೆ.',
      'armScannerOrigin': 'ಆರ್ಮ್‌ಸ್ಕ್ಯಾನರ್‌ಮೂಲ',
      'back thighs': 'ಹಿಂಭಾಗದ ತೊಡೆಗಳು',
      'back upper arms': 'ಹಿಂಭಾಗದ ಮೇಲಿನ ತೋಳುಗಳು',
      'basal metabolic': 'ಮೂಲ ಚಯಾಪಚಯ',
      'basalCalories': 'ಮೂಲ ಕ್ಯಾಲೋರಿಗಳು',
      'bloodGlucose': 'ರಕ್ತ ಗ್ಲೂಕೋಸ್',
      'bmrKcal': 'ಬಿಎಂಆರ್ಕೆಸಿಎಎಲ್',
      'body age': 'ದೇಹದ ವಯಸ್ಸು',
      'body fat': 'ದೇಹದ ಕೊಬ್ಬು',
      'body mass index': 'ದೇಹದ ದ್ರವ್ಯರಾಶಿ ಸೂಚ್ಯಂಕ',
      'body water': 'ದೇಹದ ನೀರು',
      'body weight': 'ದೇಹದ ತೂಕ',
      'body-composition report': 'ದೇಹ-ಸಂಯೋಜನೆ ವರದಿ',
      'bodyFat': 'ದೇಹದ ಕೊಬ್ಬು',
      'bodyFatPct': 'ಬಾಡಿ ಫ್ಯಾಟ್ ಪಿಸಿಟಿ',
      'bodyWaterPct': 'ಬಾಡಿ ವಾಟರ್ ಪಾರ್ಕ್',
      'bone mass': 'ಮೂಳೆ ದ್ರವ್ಯರಾಶಿ',
      'bone weight': 'ಮೂಳೆಯ ತೂಕ',
      'boneMassKg': 'ಮೂಳೆ ದ್ರವ್ಯರಾಶಿ ಕೆಜಿ',
      'book this slot': 'ಈ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಿ',
      'bookingId': 'ಬುಕಿಂಗ್ ಐಡಿ',
      'check in': 'ಚೆಕ್ ಇನ್ ಮಾಡಿ',
      'checkInAt': 'ಚೆಕ್‌ಇನ್ಅಟ್',
      'checkoutRequested': 'ಚೆಕ್ಔಟ್ ವಿನಂತಿಸಲಾಗಿದೆ',
      'continueRequested': 'ಮುಂದುವರಿಸಿ ವಿನಂತಿಸಲಾಗಿದೆ',
      'current attendance session': 'ಪ್ರಸ್ತುತ ಹಾಜರಾತಿ ಅವಧಿ',
      'departureCheckoutRequired': 'ನಿರ್ಗಮನ ಚೆಕ್ಔಟ್ ಅಗತ್ಯವಿದೆ',
      'diastolicBP': 'ಡಯಾಸ್ಟೊಲಿಕ್ ಬಿಪಿ',
      'dismissedSetupCard': 'ಸೆಟಪ್ ಕಾರ್ಡ್ ವಜಾಗೊಳಿಸಲಾಗಿದೆ',
      'e.g. Indian, Mediterranean': 'ಉದಾ: ಭಾರತೀಯ, ಮೆಡಿಟರೇನಿಯನ್',
      'e.g. peanuts': 'ಉದಾ: ಕಡಲೆಕಾಯಿ',
      'e.g., 3 bananas and 1 cup of yogurt':
          'ಉದಾಹರಣೆಗೆ, 3 ಬಾಳೆಹಣ್ಣುಗಳು ಮತ್ತು 1 ಕಪ್ ಮೊಸರು',
      'employerAggregate': 'ಉದ್ಯೋಗದಾತ ಒಟ್ಟು',
      'estimate pending': 'ಅಂದಾಜು ಬಾಕಿ ಇದೆ',
      'estimate updating': 'ಅಂದಾಜು ನವೀಕರಣ',
      'exerciseMinutes': 'ವ್ಯಾಯಾಮ ನಿಮಿಷಗಳು',
      'facilityName': 'ಸೌಲಭ್ಯದ ಹೆಸರು',
      'fat free': 'ಕೊಬ್ಬು ರಹಿತ',
      'fat percentage': 'ಕೊಬ್ಬಿನ ಶೇಕಡಾವಾರು',
      'fatFreeBodyWeightKg': 'ಕೊಬ್ಬು ಮುಕ್ತ ದೇಹತೂಕ ಕೆಜಿ',
      'front chest': 'ಮುಂಭಾಗದ ಎದೆ',
      'front thighs': 'ಮುಂಭಾಗದ ತೊಡೆಗಳು',
      'front upper arms': 'ಮುಂಭಾಗದ ಮೇಲಿನ ತೋಳುಗಳು',
      'geofenceExited': 'ಜಿಯೋಫೆನ್ಸ್ ನಿರ್ಗಮಿಸಿದೆ',
      'healthConnectRequested': 'ಆರೋಗ್ಯ ಸಂಪರ್ಕವನ್ನು ವಿನಂತಿಸಲಾಗಿದೆ',
      'healthData': 'ಆರೋಗ್ಯ ಡೇಟಾ',
      'healthSetupCompleted': 'ಆರೋಗ್ಯಸೆಟಪ್ ಪೂರ್ಣಗೊಂಡಿದೆ',
      'heartRate': 'ಹೃದಯ ಬಡಿತ',
      'hideTimer': 'ಹೈಡ್‌ಟೈಮರ್',
      'hips and glutes': 'ಸೊಂಟ ಮತ್ತು ಪೃಷ್ಠಗಳು',
      'inner thighs': 'ಒಳ ತೊಡೆಗಳು',
      'isTyping': 'ಟೈಪಿಂಗ್',
      'isUser': 'ಬಳಕೆದಾರ',
      'lower arms': 'ಕೆಳಗಿನ ತೋಳುಗಳು',
      'lower back': 'ಬೆನ್ನಿನ ಕೆಳಭಾಗ',
      'lower legs': 'ಕೆಳಗಿನ ಕಾಲುಗಳು',
      'market://details?id=com.google.android.apps.healthdata':
          'ಮಾರುಕಟ್ಟೆ://ವಿವರಗಳು?id=com.google.android.apps.healthdata',
      'mealAnalysis': 'ಊಟ ವಿಶ್ಲೇಷಣೆ',
      'medicalRecords': 'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು',
      'medicalRecordsConsented': 'ವೈದ್ಯಕೀಯ ದಾಖಲೆಗಳು ಒಪ್ಪಿಗೆ',
      'medicalShare': 'ವೈದ್ಯಕೀಯ ಹಂಚಿಕೆ',
      'metabolic age': 'ಚಯಾಪಚಯ ವಯಸ್ಸು',
      'metabolicAgeYears': 'ಚಯಾಪಚಯ ಕ್ರಿಯೆಯ ವಯಸ್ಸು',
      'mg/dL': 'ಮಿಗ್ರಾಂ/ಡೆಸಿಲೀಟರ್',
      'mindfulnessMinutes': 'ಮೈಂಡ್‌ಫುಲ್‌ನೆಸ್‌ಮಿನಿಟ್ಸ್',
      'mmHg': 'ಎಂಎಂಎಚ್‌ಜಿ',
      'muscle mass': 'ಸ್ನಾಯುವಿನ ದ್ರವ್ಯರಾಶಿ',
      'muscle weight': 'ಸ್ನಾಯುವಿನ ತೂಕ',
      'muscleMassKg': 'ಸ್ನಾಯು ದ್ರವ್ಯರಾಶಿ ಕೆಜಿ',
      'no data': 'ಡೇಟಾ ಇಲ್ಲ',
      'no workout completed': 'ಯಾವುದೇ ವ್ಯಾಯಾಮ ಪೂರ್ಣಗೊಂಡಿಲ್ಲ.',
      'non binary': 'ಬೈನರಿ ಅಲ್ಲದ',
      'not recorded': 'ದಾಖಲಾಗಿಲ್ಲ',
      'nutritionCalories': 'ಪೋಷಣೆಯ ಕ್ಯಾಲೋರಿಗಳು',
      'on track': 'ಹಾದಿಯಲ್ಲಿದೆ',
      'optional integration not configured':
          'ಐಚ್ಛಿಕ ಏಕೀಕರಣವನ್ನು ಕಾನ್ಫಿಗರ್ ಮಾಡಲಾಗಿಲ್ಲ',
      'overlaps another booking': 'ಮತ್ತೊಂದು ಬುಕಿಂಗ್ ಅನ್ನು ಅತಿಕ್ರಮಿಸುತ್ತದೆ',
      'pending review': 'ಪರಿಶೀಲನೆ ಬಾಕಿ ಇದೆ',
      'protein g': 'ಪ್ರೋಟೀನ್ ಗ್ರಾಂ',
      'proteinPct': 'ಪ್ರೋಟೀನ್‌ಪಿಸಿಟಿ',
      'radiusMeters': 'ತ್ರಿಜ್ಯಮೀಟರ್‌ಗಳು',
      'reportedBmi': 'ವರದಿಯಾಗಿದೆ ಬಿಎಂಐ',
      'request a capacity override': 'ಸಾಮರ್ಥ್ಯ ಅತಿಕ್ರಮಣವನ್ನು ವಿನಂತಿಸಿ',
      'restingHeartRate': 'ವಿಶ್ರಾಂತಿ ಹೃದಯ ದರ',
      'sessionId': 'ಸೆಷನ್ ಐಡಿ',
      'showPersistentTimer': 'ಶೋಪರ್ಸಿಸ್ಟೆಂಟ್ ಟೈಮರ್',
      'showTimer': 'ಶೋಟೈಮರ್',
      'sides of the back': 'ಹಿಂಭಾಗದ ಬದಿಗಳು',
      'skeletal muscle': 'ಅಸ್ಥಿಪಂಜರದ ಸ್ನಾಯು',
      'skeletalMusclePct': 'ಅಸ್ಥಿಪಂಜರದ ಸ್ನಾಯು',
      'sleepDuration': 'ನಿದ್ರೆಯ ಅವಧಿ',
      'sleepQuality': 'ನಿದ್ರೆಯ ಗುಣಮಟ್ಟ',
      'slotEndAt': 'ಸ್ಲಾಟ್ ಎಂಡ್‌ಎಟ್',
      'slotEndContinueRequested': 'ಸ್ಲಾಟ್ಎಂಡ್ಕಂಟಿನ್ಯೂ ವಿನಂತಿಸಲಾಗಿದೆ',
      'start an instant check-in': 'ತ್ವರಿತ ಚೆಕ್-ಇನ್ ಪ್ರಾರಂಭಿಸಿ',
      'still working': 'ಇನ್ನೂ ಕೆಲಸ ಮಾಡುತ್ತಿದ್ದೇನೆ',
      'subcutaneous fat': 'ಚರ್ಮದಡಿಯ ಕೊಬ್ಬು',
      'subcutaneousFatPct': 'ಸಬ್ಕ್ಯುಟೇನಿಯಸ್ ಫ್ಯಾಟ್ಪಿಸಿಟಿ',
      'systolicBP': 'ಸಿಸ್ಟೊಲಿಕ್ ಬಿಪಿ',
      'the end of the plan period': 'ಯೋಜನಾ ಅವಧಿಯ ಅಂತ್ಯ',
      'this facility': 'ಈ ಸೌಲಭ್ಯ',
      'upload and get me the scored dashboard back':
          'ಅಪ್‌ಲೋಡ್ ಮಾಡಿ ಮತ್ತು ಸ್ಕೋರ್ ಮಾಡಿದ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅನ್ನು ನನಗೆ ಮರಳಿ ಪಡೆಯಿರಿ.',
      'upper back': 'ಮೇಲಿನ ಬೆನ್ನು',
      'upper shoulders': 'ಮೇಲಿನ ಭುಜಗಳು',
      'visceral fat': 'ಒಳಾಂಗಗಳ ಕೊಬ್ಬು',
      'visceralFatLevel': 'ವಿಸ್ಕರಲ್ ಫ್ಯಾಟ್ ಲೆವೆಲ್',
      'water percentage': 'ನೀರಿನ ಶೇಕಡಾವಾರು',
      'waterIntake': 'ನೀರು ಸೇವನೆ',
      'weightKg': 'ತೂಕ ಕೆಜಿ',
      'your workout': 'ನಿಮ್ಮ ವ್ಯಾಯಾಮ',
      '· Edited by member': '· ಸದಸ್ಯರಿಂದ ಸಂಪಾದಿಸಲಾಗಿದೆ',
      'हिन्दी (Hindi)': 'ಹಿಂದಿ (ಹಿಂದಿ)',
      'ಕನ್ನಡ (Kannada)': 'ಕನ್ನಡ (ಕನ್ನಡ)',
      '⚖️ Log Weight': '⚖️ ತೂಕದ ದಾಖಲೆ',
      '🌙 Log Sleep': '🌙 ಲಾಗ್ ಸ್ಲೀಪ್',
      '🌙 Sleep': '🌙 ನಿದ್ರೆ',
      '🏆 You are the final winner. Your organization will contact you about the prize.':
          '🏆 ನೀವೇ ಅಂತಿಮ ವಿಜೇತರು. ಬಹುಮಾನದ ಕುರಿತು ನಿಮ್ಮ ಸಂಸ್ಥೆಯು ನಿಮ್ಮನ್ನು ಸಂಪರ್ಕಿಸುತ್ತದೆ.',
      '💧 Hydration': '💧 ಜಲಸಂಚಯನ',
      '💧 Log Water': '💧 ಲಾಗ್ ವಾಟರ್',
      '🔥 Calories': '🔥 ಕ್ಯಾಲೋರಿಗಳು',
      '🚶 Log Steps': '🚶 ಲಾಗ್ ಹಂತಗಳು',
      '🚶 Steps': '🚶 ಹಂತಗಳು',
    },
  };

  static final Map<String, List<_LocalizedPattern>> _patterns = {
    'hi': [
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ exercise\\(s\\)\\ fully\\ completed\\.\\ You\\ can\\ still\\ check\\ out\\ if\\ the\\ checklist\\ is\\ incomplete\\.\$',
        ),
        '__ARG0__ अभ्यास पूरी तरह से पूरे हो चुके हैं। यदि चेकलिस्ट अधूरी है तो भी आप चेक आउट कर सकते हैं।',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ Pts\$'), '__ARG0__ अंक'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ yrs\\ ·\\ (.*?)\$'),
        '__ARG0__ वर्ष · __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ARG0____ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)(.*?)(.*?)\$'),
        '__ARG0____ARG1____ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ measurements\\ compared\\ ·\\ (.*?)\\ changed\\ ·\\ (.*?)\\ unchanged\\\$\\{recordedOnce\\ ==\\ 0\\ \\?\$',
        ),
        '__ARG0__ मापों की तुलना की गई · __ARG1__ परिवर्तित · __ARG2__ अपरिवर्तित \${recordedOnce == 0 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\$'),
        '__ARG0__ का __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ •\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ • __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-DAY\\ SCHEDULE\$'),
        '__ARG0__-दिन अनुसूची',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ weeks\$'), '__ARG0__ सप्ताह'),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?)\\ \\\$\\{local\\.hour\\ >=\\ 12\\ \\?\$'),
        '__ARG0__:__ARG1__ \${local.hour &gt;= 12 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ exercises\\ lined\\ up\$'),
        '__ARG0__ अभ्यासों की सूची तैयार की गई',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ meals\\ planned\$'),
        '__ARG0__ भोजन की योजना बनाई गई',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ across\\ (.*?)\\ meals\$'),
        '__ARG1__ भोजन में __ARG0__ किलो कैलोरी',
      ),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ target\\.\\ Tap\\ to\\ locate\\ it\\ on\\ the\\ body\\ map\\.\$',
        ),
        '__ARG0__ लक्ष्य। इसे बॉडी मैप पर खोजने के लिए टैप करें।',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ view\$'), '__ARG0__ दृश्य'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):\\ \\\$\\{metric\\.value\\ ==\\ null\\ \\?\$'),
        '__ARG0__: \${metric.value == null ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)/\$'), '__ARG0__/'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ logged\\ successfully!\$'),
        '__ARG0__ सफलतापूर्वक लॉग इन हो गया!',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ min\$'), '__ARG0__ मिनट'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ min\\ (.*?)\\ sec\$'),
        '__ARG0__ मिनट __ARG1__ सेकंड',
      ),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ Wellness\$'), '__ARG0__ स्वास्थ्य'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ →\\ (.*?)\$'), '__ARG0__ → __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)%\\ done\$'), '__ARG0__% पूर्ण'),
      _LocalizedPattern(RegExp('^(.*?)\\ pts\$'), '__ARG0__ अंक'),
      _LocalizedPattern(RegExp('^(.*?)/\$'), '__ARG0__/'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)(.*?)\$'),
        '__ARG0__ - __ARG1____ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ authentication\\ was\\ cancelled\\.\$'),
        '__ARG0__ प्रमाणीकरण रद्द कर दिया गया।',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ reps\$'), '__ARG0__ प्रतिनिधि'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ sec\$'), '__ARG0__ सेकंड'),
      _LocalizedPattern(RegExp('^(.*?)\\ sets\$'), '__ARG0__ सेट करता है'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs/day\$'), '__ARG0__ घंटे/दिन'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal/day\$'),
        '__ARG0__ किलो कैलोरी/दिन',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ml/day\$'), '__ARG0__ मिली/दिन'),
      _LocalizedPattern(RegExp('^(.*?)\\ total\\ steps\$'), '__ARG0__ कुल चरण'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ targeted\\ \\\$\\{targetCount\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ ने \${targetCount == 1 ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{field\\.unit\\.isEmpty\\ \\?\$'),
        '__ARG0__\${field.unit.isEmpty ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)m\$'), '__ARG0__m'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__g'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\.mp4\$'),
        '__ARG0__/__ARG1__.mp4',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\.mp4\\.download\$'),
        '__ARG0__/__ARG1__.mp4.download',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(
        RegExp('^(.*?)%\\ Target\\ Met\$'),
        '__ARG0__% लक्ष्य पूरा हुआ',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)k\$'), '__ARG0__k'),
      _LocalizedPattern(RegExp('^(.*?)\\ min\$'), '__ARG0__ मिनट'),
      _LocalizedPattern(RegExp('^(.*?)k\$'), '__ARG0__k'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ CARE\\ PROGRAMS\$'),
        '__ARG0__ देखभाल कार्यक्रम',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ Wellness360\$'), '__ARG0__ वेलनेस360'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ health\\ report\$'),
        '__ARG0__ स्वास्थ्य रिपोर्ट',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ is\\ connected\\ to\\ the\\ wrong\\ product\\ server\\.\$',
        ),
        '__ARG0__ गलत उत्पाद सर्वर से जुड़ा हुआ है।',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ monitoring\\ your\\ active\\ workout\\.\$'),
        '__ARG0__ आपके सक्रिय व्यायाम की निगरानी कर रहा है।',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ report\\ comparison\$'),
        '__ARG0__ रिपोर्ट तुलना',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-health\\-report\\-(.*?)\\.pdf\$'),
        '__ARG0__-health-report-__ARG1__.pdf',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-report\\-comparison\\-(.*?)\\.pdf\$'),
        '__ARG0__-report-comparison-__ARG1__.pdf',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ \\#Wellness360\$'),
        '__ARG0__ · #Wellness360',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ changed\$'), '__ARG0__ बदल गया'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ compared\$'),
        '__ARG0__ की तुलना की गई',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{_comparison\\.newerReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${_comparison.newerReport.bmiBand == null ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{_comparison\\.olderReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${_comparison.olderReport.bmiBand == null ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ recorded\\ once\$'),
        '__ARG0__ एक बार रिकॉर्ड किया गया',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ unchanged\$'), '__ARG0__ अपरिवर्तित'),
      _LocalizedPattern(
        RegExp('^(.*?)/medifit_body_composition_(.*?)_(.*?)\\.png\$'),
        '__ARG0__/medifit_body_composition___ARG1_____ARG2__.png',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ (.*?)\\ min\$'),
        '__ARG0__ · __ARG1__ मिनट',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Duration\\ not\\ recorded\$'),
        '__ARG0__ · अवधि दर्ज नहीं की गई',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{_comparison\\.elapsedDays\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${_comparison.elapsedDays == 1 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ml\\ /\\ (.*?)\\ ml\$'),
        '__ARG0__ मिली / __ARG1__ मिली',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ →\\ (.*?)\$'), '__ARG0__ → __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ to\\ (.*?)\$'),
        '__ARG0__ से __ARG1__ तक',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ –\\ \\\$\\{p\\.endsOn\\ ==\\ null\\ \\?\$'),
        '__ARG0__ – \${p.endsOn == null ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ –\\ (.*?)\$'), '__ARG0__ – __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs\$'), '__ARG0__ घंटे'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ARG0__/__ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{program\\.completedAt\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${program.completedAt == null ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{program\\.completionSummary\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${program.completionSummary == null ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{comparison\\.newerReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${comparison.newerReport.bmiBand == null ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{comparison\\.olderReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${comparison.olderReport.bmiBand == null ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal/day\$'),
        '__ARG0__ किलो कैलोरी/दिन',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(RegExp('^(.*?)\\ years\$'), '__ARG0__ वर्ष'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{report\\.bmiBand\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${report.bmiBand == null ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\-\\\$\\{_selectedDob\\.month\\.toString\\(\\)\\.padLeft\\(2,\$',
        ),
        '__ARG0__-\${_selectedDob.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(RegExp('^(.*?)/10\$'), '__ARG0__/10'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)/(.*?)\$'),
        '__ARG0__ __ARG1__/__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ACTIVE\$'), '__ARG0__ सक्रिय'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ ·\\ (.*?)g\\ protein\$'),
        '__ARG0__ किलो कैलोरी · __ARG1__ ग्राम प्रोटीन',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs\$'), '__ARG0__ घंटे'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ml\$'), '__ARG0__ मिलीलीटर'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)%\$'), '__ARG0__: __ARG1__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ burned\$'),
        '__ARG0__ किलो कैलोरी जली',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ joined\$'), '__ARG0__ शामिल हो गया'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ participants\$'),
        '__ARG0__ प्रतिभागी',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Goal:\\ (.*?)\$'),
        '__ARG0__ · लक्ष्य: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{comparison\\.elapsedDays\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${comparison.elapsedDays == 1 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ metrics\\ ·\\ (.*?)\\ days\\ elapsed\$'),
        '__ARG0__ मेट्रिक्स · __ARG1__ बीते दिन',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ available\\ in\\ your\\ history\\.\$'),
        '__ARG0__ आपके इतिहास में उपलब्ध है।',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ sets(.*?)\$'),
        '__ARG0__/__ARG1__ सेट__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ remains\\ active\$'),
        '__ARG0__ सक्रिय रहता है',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ /\\ (.*?)\\ ml\$'),
        '__ARG0__ / __ARG1__ मिलीलीटर',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ cm\$'), '__ARG0__ सेमी'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ exercises\$'), '__ARG0__ अभ्यास'),
      _LocalizedPattern(RegExp('^(.*?)\\ meals\$'), '__ARG0__ भोजन'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(
        RegExp('^(.*?):\\ \\\$\\{hasWorkout\\ \\?\$'),
        '__ARG0__: \${hasWorkout ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{day\\.month\\.toString\\(\\)\\.padLeft\\(2,\$'),
        '__ARG0__-\${day.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{dayFirst\\.group\\(2\\)!\\.padLeft\\(2,\$'),
        '__ARG0__-\${dayFirst.group(2)!.padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ days\\ left\$'),
        '__ARG0__ दिन शेष हैं',
      ),
      _LocalizedPattern(RegExp('^(.*?)d\\ ago\$'), '__ARG0__d ago'),
      _LocalizedPattern(RegExp('^(.*?)h\\ ago\$'), '__ARG0__ घंटे पहले'),
      _LocalizedPattern(RegExp('^(.*?)m\\ ago\$'), '__ARG0__m पहले'),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__h'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{e\\.message\\ \\?\\?\$'),
        '__ARG0__ \${e.message ??',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ alerts\\ on\$'), '__ARG0__ अलर्ट'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ exercises\\ completed\$'),
        '__ARG0__ में से __ARG1__ अभ्यास पूरे हो गए',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ assigned\\ sets\\ completed\$'),
        '__ARG0__ के __ARG1__ असाइन किए गए सेट पूरे हो गए',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\\ complete\$'), '__ARG0__% पूर्ण'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ must\\ be\\ a\\ number\\.\$'),
        '__ARG0__ एक संख्या होनी चाहिए।',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\.download\$'), '__ARG0__.डाउनलोड'),
      _LocalizedPattern(
        RegExp('^(.*?)%\\ \\\$\\{percentage\\ >\\ 0\\ \\?\$'),
        '__ARG0__% \${प्रतिशत &gt; 0 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ than\\ earlier\$'),
        '__ARG0__ __ARG1__ पहले की तुलना में',
      ),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__h'),
      _LocalizedPattern(RegExp('^(.*?)h\\ (.*?)m\$'), '__ARG0__h __ARG1__m'),
      _LocalizedPattern(RegExp('^(.*?)\\ of\\ 5\$'), '__ARG0__ का 5'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{iso\\.group\\(2\\)!\\.padLeft\\(2,\$'),
        '__ARG0__-\${iso.group(2)!.padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Published\\ (.*?)\$'),
        '__ARG0__ · प्रकाशित __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ sets\$'),
        '__ARG0__/__ARG1__ सेट',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)/(.*?)\\ sets\\\$\\{item\\.reps\\ ==\\ null\\ \\|\\|\\ item\\.reps!\\.isEmpty\\ \\?\$',
        ),
        '__ARG0__/__ARG1__ सेट\${item.reps == null || item.reps!.isEmpty ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ARG0__/__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ extra\\ sets\$'),
        '__ARG0__/__ARG1__ अतिरिक्त सेट',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ARG0__/__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ml\\ logged\$'),
        '__ARG0__ एमएल लॉग किया गया',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ to\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ से __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{metric\\.unit\\.trim\\(\\)\\.isEmpty\\ \\?\$'),
        '__ARG0__\${metric.unit.trim().isEmpty ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):\\ (.*?)\\ to\\ (.*?)\\ (.*?)\$'),
        '__ARG0__: __ARG1__ से __ARG2__ __ARG3__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?),\\ (.*?)\$'),
        '__ARG0__ __ARG1__, __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?),\\ (.*?)\$'),
        '__ARG0__ __ARG1__, __ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)m\$'), '__ARG0__m'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{month\\.toString\\(\\)\\.padLeft\\(2,\$'),
        '__ARG0__-\${month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal/day\$'),
        '__ARG0__ किलो कैलोरी/दिन',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ days/week\$'), '__ARG0__ दिन/सप्ताह'),
      _LocalizedPattern(RegExp('^(.*?)\\ meals/day\$'), '__ARG0__ भोजन/दिन'),
      _LocalizedPattern(RegExp('^(.*?)\\ min/session\$'), '__ARG0__ मिनट/सत्र'),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ARG0____ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__h'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ progress\\ \\-\\ (.*?)\$'),
        '__ARG0__ प्रगति - __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ •\\ (.*?)\$'), '__ARG0__ • __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\\ (.*?):(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__ __ARG3__:__ARG4__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ estimated\$'),
        '__ARG0__ किलो कैलोरी अनुमानित',
      ),
      _LocalizedPattern(RegExp('^(.*?)s\\ rest\$'), '__ARG0__s शेष'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{results\\.length\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${results.length == 1 ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ qualifying\\ days\$'),
        '__ARG0__ योग्यता दिवस',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ verified\\ steps\$'),
        '__ARG0__ सत्यापित चरण',
      ),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__h'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ places\\ left\$'),
        'शेष __ARG0__ स्थान',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ARG0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ expected\\ actions\$'),
        '__ARG0__ की __ARG1__ अपेक्षित क्रियाएँ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ expected\\ actions\\ completed\$'),
        '__ARG0__ में से __ARG1__ की अपेक्षित क्रियाएँ पूरी हो गईं',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/medifit_exercise_videos\$'),
        '__ARG0__/medifit_exercise_videos',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ bpm\$'), '__ARG0__ बीपीएम'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ किलो कैलोरी'),
      _LocalizedPattern(RegExp('^(.*?)\\ ml\$'), '__ARG0__ मिलीलीटर'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ session(.*?)\$'),
        '__ARG0__ सत्र__ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{const\\ \\[\$'),
        '__ARG0__ \${स्थिरांक [',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ waiting\\ for\\ your\\ review\\.\$'),
        '__ARG0__ आपकी समीक्षा की प्रतीक्षा कर रहा है।',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ (.*?)\$'), '__ARG0__ __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ bpm\$'), '__ARG0__ बीपीएम'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\-\\\$\\{value\\.month\\.toString\\(\\)\\.padLeft\\(2,\$',
        ),
        '__ARG0__-\${value.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?),\\ (.*?)\\ (.*?)\$'),
        '__ARG0__, __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ किलोग्राम'),
      _LocalizedPattern(RegExp('^(.*?)\\ PROGRESS\$'), '__ARG0__ प्रगति'),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ARG0____ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^\\+(.*?)\\ ml\$'), '+__ARG0__ मिलीलीटर'),
      _LocalizedPattern(RegExp('^\\-\\ (.*?)\$'), '- __ARG0__'),
      _LocalizedPattern(RegExp('^/(.*?)\$'), '/__ARG0__'),
      _LocalizedPattern(RegExp('^/(.*?)\$'), '/__ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^2026\\ (.*?)\\.\\ Secure\\ HIPAA\\ compliant\\ registration\\.\$',
        ),
        '2026 __ARG0__. सुरक्षित HIPAA अनुपालन पंजीकरण।',
      ),
      _LocalizedPattern(
        RegExp(
          '^================\\ (.*?)\\ API\\ REQUEST\\ ================\$',
        ),
        '================ __ARG0__ API अनुरोध ================',
      ),
      _LocalizedPattern(
        RegExp(
          '^================\\ (.*?)\\ API\\ RESPONSE\\ ================\$',
        ),
        '================ __ARG0__ API प्रतिक्रिया ================',
      ),
      _LocalizedPattern(
        RegExp('^AI\\ chat\\ error:\\ (.*?)\$'),
        'एआई चैट त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^API\\ Error:\\ (.*?)\$'),
        'एपीआई त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^API\\ Profile\\ load\\ failed,\\ falling\\ back\\ to\\ local:\\ (.*?)\$',
        ),
        'API प्रोफ़ाइल लोड करने में विफल, स्थानीय सर्वर पर वापस जा रहा है: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Active:\\ (.*?)%\$'), 'सक्रिय: __ARG0__%'),
      _LocalizedPattern(RegExp('^App\\ BMI\\ (.*?)\$'), 'ऐप बीएमआई __ARG0__'),
      _LocalizedPattern(
        RegExp('^Apple\\ Authentication\\ error:\\ (.*?)\$'),
        'एप्पल प्रमाणीकरण त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Attendance\\ request\\ failed\\ \\((.*?)\\)\$'),
        'उपस्थिति अनुरोध विफल (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Authentication\\ failed:\\ (.*?)\$'),
        'प्रमाणीकरण विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Avg\\ (.*?)\\ ml\\ ·\\ Total\\ (.*?)\\ ml\\ ·\\ (.*?)\\ points\$',
        ),
        'औसत __ARG0__ मिलीलीटर · कुल __ARG1__ मिलीलीटर · __ARG2__ अंक',
      ),
      _LocalizedPattern(
        RegExp('^Background\\ HealthKit\\ sync\\ failed:\\ (.*?)\$'),
        'बैकग्राउंड हेल्थकिट सिंक विफल: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'धारक __ARG0__'),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'धारक __ARG0__'),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'धारक __ARG0__'),
      _LocalizedPattern(RegExp('^Body:\\ (.*?)\$'), 'बॉडी: __ARG0__'),
      _LocalizedPattern(RegExp('^C\\ (.*?)g\$'), 'C __ARG0__g'),
      _LocalizedPattern(
        RegExp(
          '^Cannot\\ reach\\ the\\ API\\ at\\ (.*?)\\.\\ On\\ a\\ physical\\ phone\\ this\\ must\\ be\\ your\\ Mac\\ Wi\\-Fi\\ IP,\\ and\\ wellness\\-server\\ must\\ be\\ running\\.\$',
        ),
        '__ARG0__ पर API तक नहीं पहुँचा जा सकता। भौतिक फ़ोन पर यह आपके Mac का वाई-फ़ाई IP होना चाहिए, और वेलनेस सर्वर चालू होना चाहिए।',
      ),
      _LocalizedPattern(
        RegExp('^Chat\\ history\\ bootstrap\\ failed:\\ (.*?)\$'),
        'चैट इतिहास बूटस्ट्रैप विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Checked\\ out\\ at\\ (.*?)\\.\\ Your\\ workout\\ report\\ is\\ being\\ prepared\\.\$',
        ),
        'चेकआउट __ARG0__ पर हो गया है। आपकी वर्कआउट रिपोर्ट तैयार की जा रही है।',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ a\\ facility\\ and\\ (.*?)\\ slot\$'),
        'एक सुविधा और __ARG0__ स्लॉट चुनें',
      ),
      _LocalizedPattern(
        RegExp(
          '^Choose\\ a\\ facility\\ and\\ hourly\\ (.*?)\\ availability\$',
        ),
        'एक सुविधा और प्रति घंटा उपलब्धता चुनें',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ a\\ facility\\ for\\ (.*?)\$'),
        '__ARG0__ के लिए एक सुविधा चुनें',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ how\\ (.*?)\\ looks\\ on\\ this\\ device\$'),
        'इस डिवाइस पर __ARG0__ कैसा दिखेगा, यह चुनें',
      ),
      _LocalizedPattern(RegExp('^Completed\\ (.*?)\$'), '__ARG0__ पूर्ण हुआ'),
      _LocalizedPattern(
        RegExp(
          '^Connect\\ to\\ import\\ steps,\\ heart\\ rate,\\ sleep\\ metrics,\\ active\\ calories,\\ body\\ weight,\\ blood\\ pressure,\\ hydration,\\ and\\ nutrition\\ directly\\ from\\ (.*?)\\.\$',
        ),
        'कदमों की संख्या, हृदय गति, नींद संबंधी आंकड़े, सक्रिय कैलोरी, शरीर का वजन, रक्तचाप, जलयोजन और पोषण संबंधी जानकारी को सीधे __ARG0__ से आयात करने के लिए कनेक्ट करें।',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ create\\ PDF:\\ (.*?)\$'),
        'पीडीएफ नहीं बनाई जा सकी: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ delete\\ the\\ comparison:\\ (.*?)\$'),
        'तुलना को हटाया नहीं जा सका: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ delete\\ the\\ report:\\ (.*?)\$'),
        'रिपोर्ट को हटाया नहीं जा सका: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ exercise\\ videos\\ \\((.*?)\\)\$'),
        'व्यायाम वीडियो लोड नहीं हो सके (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ privacy\\ settings:\\ (.*?)\$'),
        'गोपनीयता सेटिंग्स लोड नहीं हो सकीं: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ reports:\\ (.*?)\$'),
        'रिपोर्ट लोड नहीं हो सकीं: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ refresh\\ your\\ meal\\ tracker:\\ (.*?)\$'),
        'आपके मील ट्रैकर को रीफ़्रेश नहीं किया जा सका: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ update\\ the\\ report:\\ (.*?)\$'),
        'रिपोर्ट अपडेट नहीं हो सकी: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ upload\\ the\\ report:\\ (.*?)\$'),
        'रिपोर्ट अपलोड नहीं हो सकी: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ verify\\ the\\ (.*?)\\ server\\.\$'),
        '__ARG0__ सर्वर को सत्यापित नहीं किया जा सका।',
      ),
      _LocalizedPattern(
        RegExp('^Couldn\'t\\ load\\ companies/facilities:\\ (.*?)\$'),
        'कंपनियां/सुविधाएं लोड नहीं हो सकीं: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Couldn\'t\\ load\\ facilities\\ for\\ this\\ company:\\ (.*?)\$',
        ),
        'इस कंपनी के लिए सुविधाएं लोड नहीं हो सकीं: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Daily\\ Progress:\\ (.*?)%\$'),
        'दैनिक प्रगति: __ARG0__%',
      ),
      _LocalizedPattern(
        RegExp('^Daily\\ calorie\\ target:\\ (.*?)\\ kcal\$'),
        'दैनिक कैलोरी लक्ष्य: __ARG0__ किलो कैलोरी',
      ),
      _LocalizedPattern(
        RegExp('^Dashboard\\ GET\\ Response:\\ (.*?)\$'),
        'डैशबोर्ड GET प्रतिक्रिया: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Days\\ per\\ week:\\ (.*?)\$'),
        'प्रति सप्ताह दिन: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Delete\\ “(.*?)”\\ and\\ all\\ of\\ its\\ messages\\?\\ This\\ cannot\\ be\\ undone\\.\$',
        ),
        '“__ARG0__” और इसके सभी संदेशों को हटाना है? इसे पूर्ववत नहीं किया जा सकता है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Detailed\\ (.*?)\\ anatomy\\ map\\.\\ (.*?)\\ is\\ focused\\ in\\ red\\.\$',
        ),
        'विस्तृत __ARG0__ शारीरिक संरचना का नक्शा। __ARG1__ को लाल रंग में दर्शाया गया है।',
      ),
      _LocalizedPattern(
        RegExp('^Device\\ token\\ registration\\ error:\\ (.*?)\$'),
        'डिवाइस टोकन पंजीकरण त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Earlier\\ (.*?)\\ to\\ latest\\ (.*?)\$'),
        'पहले __ARG0__ से लेकर नवीनतम __ARG1__ तक',
      ),
      _LocalizedPattern(
        RegExp('^Earlier\\ ·\\ (.*?)\$'),
        'इससे पहले · __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Edit\\ (.*?)\$'), '__ARG0__ संपादित करें'),
      _LocalizedPattern(
        RegExp('^Enter\\ a\\ value\\ between\\ (.*?)\\ and\\ (.*?)\\.\$'),
        '__ARG0__ और __ARG1__ के बीच कोई मान दर्ज करें।',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ checking\\ health\\ permissions:\\ (.*?)\$'),
        'स्वास्थ्य अनुमतियों की जाँच में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ configuring\\ HealthService:\\ (.*?)\$'),
        'हेल्थ सर्विस को कॉन्फ़िगर करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ deleting\\ log:\\ (.*?)\$'),
        'लॉग हटाने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ disconnecting\\ Google\\ Sign\\-In:\\ (.*?)\$'),
        'गूगल साइन-इन डिस्कनेक्ट करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ during\\ full\\ daily\\ records\\ fetch:\\ (.*?)\$'),
        'पूरे दैनिक रिकॉर्ड प्राप्त करने के दौरान त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ Android\\ Health\\ Connect\\ status:\\ (.*?)\$',
        ),
        'एंड्रॉइड हेल्थ कनेक्ट की स्थिति प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ active\\ challenges\\ for\\ dashboard:\\ (.*?)\$',
        ),
        'डैशबोर्ड के लिए सक्रिय चुनौतियों को प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ health\\ data\\ in\\ batch:\\ (.*?)\$',
        ),
        'बैच में दैनिक स्वास्थ्य डेटा प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ health\\ data\\ type\\ (.*?)\\ in\\ fallback:\\ (.*?)\$',
        ),
        'फ़ॉलबैक में दैनिक स्वास्थ्य डेटा प्रकार __ARG0__ प्राप्त करने में त्रुटि: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ sleep\\ data\\ in\\ batch:\\ (.*?)\$',
        ),
        'बैच में दैनिक नींद डेटा प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ for\\ period:\\ (.*?)\$'),
        'अवधि __ARG0__ के लिए स्वास्थ्य डेटा प्राप्त करने में त्रुटि',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ in\\ batch:\\ (.*?)\$'),
        'बैच में स्वास्थ्य डेटा प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ type\\ (.*?):\\ (.*?)\$'),
        'स्वास्थ्य डेटा प्रकार __ARG0__ प्राप्त करने में त्रुटि: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ iOS\\ medical\\ data:\\ (.*?)\$'),
        'iOS चिकित्सा डेटा प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ points\\ balance:\\ (.*?)\$'),
        'पॉइंट बैलेंस प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ sleep\\ data:\\ (.*?)\$'),
        'नींद संबंधी डेटा प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ today\'s\\ health\\ data:\\ (.*?)\$'),
        'आज के स्वास्थ्य डेटा को प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ today\'s\\ sleep\\ data:\\ (.*?)\$'),
        'आज के नींद संबंधी डेटा को प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ water\\ graph:\\ (.*?)\$'),
        'जल ग्राफ प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ water\\ logs:\\ (.*?)\$'),
        'जल लॉग प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ aggregated\\ steps:\\ (.*?)\$'),
        'एकत्रित चरणों को प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ steps\\ for\\ (.*?):\\ (.*?)\$'),
        '__ARG0__ के लिए चरण प्राप्त करने में त्रुटि: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ steps\\ for\\ today:\\ (.*?)\$'),
        'आज के चरणों को प्राप्त करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ in\\ _fetchRealData\\ combined\\ flow:\\ (.*?)\$'),
        '_fetchRealData संयुक्त प्रवाह में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ in\\ _syncAndRefreshDashboard\\ combined\\ flow:\\ (.*?)\$',
        ),
        '_syncAndRefreshDashboard संयुक्त प्रवाह में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ joining\\ challenge:\\ (.*?)\$'),
        'चैलेंज में शामिल होने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ challenges:\\ (.*?)\$'),
        'चुनौतियाँ लोड करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ data:\\ (.*?)\$'),
        'डेटा लोड करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ notification\\ settings:\\ (.*?)\$'),
        'अधिसूचना सेटिंग्स लोड करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ persistent\\ cache:\\ (.*?)\$'),
        'स्थायी कैश लोड करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ profile:\\ (.*?)\$'),
        'प्रोफ़ाइल लोड करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ logging\\ water\\ locally:\\ (.*?)\$'),
        'स्थानीय स्तर पर जल लॉग करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ processing\\ health\\ data\\ for\\ (.*?):\\ (.*?)\$'),
        '__ARG0__ के लिए स्वास्थ्य डेटा संसाधित करने में त्रुटि: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ requesting\\ health\\ permissions:\\ (.*?)\$'),
        'स्वास्थ्य संबंधी अनुमतियाँ अनुरोध करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ requesting\\ iOS\\ medical\\ permissions:\\ (.*?)\$'),
        'iOS चिकित्सा अनुमतियों का अनुरोध करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ saving\\ persistent\\ cache:\\ (.*?)\$'),
        'स्थायी कैश सहेजने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ syncing\\ custom\\ goals\\ to\\ backend\\ server:\\ (.*?)\$',
        ),
        'कस्टम लक्ष्यों को बैकएंड सर्वर से सिंक्रनाइज़ करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ syncing\\ logged\\ water\\ to\\ backend:\\ (.*?)\$'),
        'लॉग किए गए पानी को बैकएंड से सिंक्रनाइज़ करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ syncing\\ manual\\ logged\\ water:\\ (.*?)\$'),
        'मैन्युअल रूप से लॉग किए गए पानी को सिंक्रनाइज़ करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ updating\\ log:\\ (.*?)\$'),
        'लॉग अपडेट करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ updating\\ profile:\\ (.*?)\$'),
        'प्रोफ़ाइल अपडेट करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Error:\\ (.*?)\$'), 'त्रुटि: __ARG0__'),
      _LocalizedPattern(RegExp('^Exercise\\ (.*?)\$'), 'अभ्यास __ARG0__'),
      _LocalizedPattern(
        RegExp('^Extra\\ set\\ (.*?)\$'),
        'अतिरिक्त सेट __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Extra\\ set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        'अतिरिक्त सेट __ARG0__ · __ARG1__ रेप्स',
      ),
      _LocalizedPattern(RegExp('^F\\ (.*?)g\$'), 'एफ __एआरजी0__जी'),
      _LocalizedPattern(
        RegExp('^Facility\\ feedback\\ request\\ failed\\ \\((.*?)\\)\$'),
        'सुविधा संबंधी प्रतिक्रिया अनुरोध विफल रहा (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Facility\\ request\\ failed\\ \\((.*?)\\)\$'),
        'सुविधा अनुरोध विफल (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ add\\ nutrition\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'पोषण लॉग जोड़ने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ add\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'जल लॉग जोड़ने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ authenticate\\ with\\ (.*?):\\ (.*?)\$'),
        '__ARG0__ के साथ प्रमाणीकरण विफल: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ call\\ (.*?)\$'),
        '__ARG0__ को कॉल करने में विफल रहा',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ compare\\ reports:\\ (.*?)\\ (.*?)\$'),
        'रिपोर्टों की तुलना करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ connect\\ to\\ server:\\ (.*?)\$'),
        'सर्वर से कनेक्ट करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ create\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS संपर्क बनाने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ delete\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS संपर्क हटाने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'तुलना हटाने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'स्वास्थ्य रिपोर्ट को हटाने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ delete\\ nutrition\\ log:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'पोषण लॉग को हटाने में विफलता: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'जल लॉग को हटाने में विफलता: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete:\\ (.*?)\$'),
        'हटाने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ fetch\\ challenges:\\ (.*?)\$'),
        'चुनौतियाँ प्राप्त करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ fetch\\ daily\\ records\\ for\\ sync\\.\\ Proceeding\\ with\\ empty\\.\\ Error:\\ (.*?)\$',
        ),
        'सिंक के लिए दैनिक रिकॉर्ड प्राप्त करने में विफलता। खाली ही आगे बढ़ रहे हैं। त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ fetch\\ notification\\ settings\\ from\\ API,\\ loading\\ fallback\\ cache:\\ (.*?)\$',
        ),
        'API से अधिसूचना सेटिंग्स प्राप्त करने में विफल, फ़ॉलबैक कैश लोड हो रहा है: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ get\\ dashboard:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'डैशबोर्ड प्राप्त करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ join\\ challenge:\\ (.*?)\$'),
        'चुनौती में शामिल होने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ SOS\\ contacts:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'SOS संपर्क लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ SOS\\ data:\\ (.*?)\$'),
        'SOS डेटा लोड करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ challenges\\ from\\ server\\ \\((.*?)\\)\$',
        ),
        'सर्वर (__ARG0__) से चुनौतियाँ लोड करने में विफल।',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'तुलना लोड करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ comparisons:\\ (.*?)\\ (.*?)\$'),
        'तुलनाएँ लोड करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ correction\\ history:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'सुधार इतिहास लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ emergency\\ numbers:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'आपातकालीन नंबर लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ goals\\ from\\ server,\\ using\\ local\\ cache:\\ (.*?)\$',
        ),
        'सर्वर से लक्ष्य लोड करने में विफल, स्थानीय कैश का उपयोग किया जा रहा है: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ goals:\\ (.*?)\$'),
        'लक्ष्य लोड करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ graph\\ data:\\ (.*?)\$'),
        'ग्राफ़ डेटा लोड करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ health\\ reports:\\ (.*?)\\ (.*?)\$'),
        'स्वास्थ्य रिपोर्ट लोड करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ mood\\ check\\-ins:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'मूड चेक-इन लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ notifications:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'सूचनाएं लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ nutrition\\ logs:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'पोषण लॉग लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ today\'s\\ nutrition\\ totals:\\ (.*?)\$',
        ),
        'आज के पोषण संबंधी कुल आंकड़े लोड करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ user\\ profile:\\ (.*?)\$'),
        'उपयोगकर्ता प्रोफ़ाइल लोड करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ water\\ graph:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'जल ग्राफ लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ water\\ logs:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'जल लॉग लोड करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ mark\\ notification\\ read:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'सूचना को पढ़ा हुआ चिह्नित करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ migrate\\ health\\ connection\\ status:\\ (.*?)\$',
        ),
        'स्वास्थ्य कनेक्शन स्थिति को स्थानांतरित करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ persist\\ health\\ connection\\ status:\\ (.*?)\$',
        ),
        'स्वास्थ्य कनेक्शन स्थिति को बनाए रखने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ register\\ device\\ token:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'डिवाइस टोकन पंजीकृत करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ save\\ correction:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'सुधार सहेजने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ submit\\ enrolment\\ to\\ server:\\ (.*?)\$'),
        'सर्वर __ARG0__ पर नामांकन सबमिट करने में विफल।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ submit\\ mood\\ check\\-in:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'मूड चेक-इन सबमिट करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ sync\\ dashboard:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'डैशबोर्ड को सिंक करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ sync\\ water\\ log:\\ (.*?)\$'),
        'जल लॉग को सिंक्रनाइज़ करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ trigger\\ SOS:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'SOS ट्रिगर करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ undo\\ correction:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'सुधार को पूर्ववत करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ update\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS संपर्क अपडेट करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'तुलना को अपडेट करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'स्वास्थ्य रिपोर्ट अपडेट करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ update\\ notification\\ setting\\ on\\ API:\\ (.*?)\$',
        ),
        'API __ARG0__ पर अधिसूचना सेटिंग अपडेट करने में विफल।',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ profile:\\ (.*?)\$'),
        'प्रोफ़ाइल अपडेट करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ settings:\\ (.*?)\$'),
        'सेटिंग्स अपडेट करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ user\\ profile:\\ (.*?)\$'),
        'उपयोगकर्ता प्रोफ़ाइल अपडेट करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'जल लॉग अपडेट करने में विफल: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update:\\ (.*?)\$'),
        'अपडेट करने में विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ upload\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'स्वास्थ्य रिपोर्ट अपलोड करने में विफल: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(RegExp('^Fair\\ \\((.*?)%\\)\$'), 'उचित (__ARG0__%)'),
      _LocalizedPattern(
        RegExp('^Feeling:\\ (.*?)\\ ·\\ Progress:\\ (.*?)\$'),
        'भावना: __ARG0__ · प्रगति: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^For\\ the\\ signed\\-in\\ (.*?)\\ member\$'),
        'लॉग इन किए हुए __ARG0__ सदस्य के लिए',
      ),
      _LocalizedPattern(
        RegExp(
          '^Force\\ updated\\ local\\ water\\ intake\\ cache\\ to:\\ (.*?)\\ ml\$',
        ),
        'स्थानीय जल सेवन कैश को __ARG0__ मिली में अपडेट करने के लिए बाध्य किया गया।',
      ),
      _LocalizedPattern(
        RegExp('^Forgot\\ Password\\ API\\ error:\\ (.*?)\$'),
        'पासवर्ड भूल गए API त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^General\\ error\\ during\\ health\\ data\\ fetching:\\ (.*?)\$',
        ),
        'स्वास्थ्य डेटा प्राप्त करने के दौरान सामान्य त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Get\\ (.*?)\\ plan\$'),
        '__ARG0__ प्लान प्राप्त करें',
      ),
      _LocalizedPattern(
        RegExp('^Goal:\\ (.*?)\\ hrs\$'),
        'लक्ष्य: __ARG0__ घंटे',
      ),
      _LocalizedPattern(RegExp('^Goal:\\ (.*?)\$'), 'लक्ष्य: __ARG0__'),
      _LocalizedPattern(RegExp('^Goal:\\ (.*?)h\$'), 'लक्ष्य: __ARG0__h'),
      _LocalizedPattern(RegExp('^Good\\ \\((.*?)%\\)\$'), 'अच्छा (__ARG0__%)'),
      _LocalizedPattern(
        RegExp('^Google\\ Authentication\\ error:\\ (.*?)\$'),
        'गूगल प्रमाणीकरण त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Have\\ you\\ left\\ (.*?)\\?\$'),
        'क्या आपने __ARG0__ छोड़ दिया है?',
      ),
      _LocalizedPattern(
        RegExp('^Health\\ authorization\\ request\\ returned:\\ (.*?)\$'),
        'स्वास्थ्य प्राधिकरण अनुरोध का उत्तर: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Health\\ report\\ ·\\ (.*?)\$'),
        'स्वास्थ्य रिपोर्ट · __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ agree\\ to\\ (.*?)\'s\\ terms\\ of\\ service\\ and\\ program\\ participation\\ rules\\.\$',
        ),
        'मैं __ARG0__ की सेवा शर्तों और कार्यक्रम में भागीदारी के नियमों से सहमत हूँ।',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ (.*?)\\ collecting\\ my\\ wearable/health\\ metrics\\ \\(steps,\\ sleep,\\ heart\\ rate\\)\\ to\\ power\\ my\\ wellness\\ dashboard\\.\$',
        ),
        'मैं अपनी वेलनेस डैशबोर्ड को संचालित करने के लिए __ARG0__ को मेरे पहनने योग्य/स्वास्थ्य संबंधी मेट्रिक्स (कदम, नींद, हृदय गति) एकत्र करने की सहमति देता/देती हूं।',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ AI\\ processing\\ for\\ my\\ (.*?)\\ plan\$',
        ),
        'मैं अपने __ARG0__ प्लान के लिए AI प्रोसेसिंग की सहमति देता/देती हूँ।',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ sharing\\ relevant\\ medical\\ assessment\\ answers\\ with\\ (.*?)\'s\\ clinical\\ staff\\ for\\ clearance\\ review,\\ where\\ applicable\\.\$',
        ),
        'मैं जहां लागू हो, प्रासंगिक चिकित्सा मूल्यांकन संबंधी उत्तरों को मंजूरी समीक्षा के लिए __ARG0__ के नैदानिक ​​कर्मचारियों के साथ साझा करने के लिए सहमति देता हूं।',
      ),
      _LocalizedPattern(
        RegExp('^Initialized\\ water\\ intake\\ from\\ API:\\ (.*?)\\ ml\$'),
        'एपीआई से प्रारंभिक जल सेवन: __ARG0__ मिलीलीटर',
      ),
      _LocalizedPattern(
        RegExp('^Issue\\ assigned\\ to\\ (.*?)\\.\$'),
        'समस्या __ARG0__ को सौंपी गई है।',
      ),
      _LocalizedPattern(
        RegExp('^Joined\\ (.*?)\\ challenge!\$'),
        '__ARG0__ चैलेंज में शामिल हुआ!',
      ),
      _LocalizedPattern(
        RegExp('^Last\\ sync:\\ (.*?):(.*?):(.*?)\$'),
        'अंतिम सिंक: __ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(RegExp('^Latest\\ ·\\ (.*?)\$'), 'नवीनतम · __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^Loaded\\ persistent\\ HealthData\\ cache\\ \\(timestamp:\\ (.*?)\\)\$',
        ),
        'स्थायी स्वास्थ्य डेटा कैश लोड किया गया (टाइमस्टैम्प: __ARG0__)',
      ),
      _LocalizedPattern(
        RegExp(
          '^Loaded\\ persistent\\ daily\\ records\\ cache\\ \\(timestamp:\\ (.*?)\\)\$',
        ),
        'स्थायी दैनिक रिकॉर्ड कैश लोड किया गया (टाइमस्टैम्प: __ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Log\\ (.*?)\\ Manually\$'),
        'लॉग __ARG0__ मैन्युअल रूप से',
      ),
      _LocalizedPattern(
        RegExp('^Logged\\ \\+(.*?)\\ ml\\ of\\ water!\$'),
        '+__ARG0__ मिलीलीटर पानी दर्ज किया गया!',
      ),
      _LocalizedPattern(
        RegExp('^Login\\ API\\ error:\\ (.*?)\$'),
        'लॉगिन एपीआई त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Login\\ With\\ Code\\ API\\ error:\\ (.*?)\$'),
        'लॉगिन विद कोड एपीआई त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Meals\\ per\\ day:\\ (.*?)\$'),
        'प्रतिदिन भोजन की संख्या: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Measured\\ (.*?)\$'), 'मापा गया __ARG0__'),
      _LocalizedPattern(
        RegExp('^Member\\ copy\\ \\-\\ generated\\ (.*?)\$'),
        'सदस्य प्रतिलिपि - जनरेट की गई __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Method:\\ (.*?)\$'), 'विधि: __ARG0__'),
      _LocalizedPattern(RegExp('^Mind:\\ (.*?)%\$'), 'मन: __ARG0__%'),
      _LocalizedPattern(
        RegExp('^Mood\\ (.*?)/10\\ ·\\ (.*?)\$'),
        'मूड __ARG0__/10 · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Mood\\ check\\-in\\ history\\ error:\\ (.*?)\$'),
        'मूड चेक-इन इतिहास त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Network\\ error:\\ (.*?)\$'),
        'नेटवर्क त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Next\\ review:\\ (.*?)\$'),
        'अगली समीक्षा: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Next:\\ (.*?)\$'), 'अगला: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Next:\\ (.*?)\\ ·\\ (.*?)\$'),
        'अगला: __ARG0__ · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Notification\\ inbox\\ error:\\ (.*?)\$'),
        'नोटिफिकेशन इनबॉक्स त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Nutrition:\\ (.*?)%\$'), 'पोषण: __ARG0__%'),
      _LocalizedPattern(RegExp('^P\\ (.*?)g\$'), 'पी __एआरजी0__जी'),
      _LocalizedPattern(
        RegExp('^Page\\ (.*?)\\ of\\ (.*?)\$'),
        'पृष्ठ __ARG0__ का __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Page\\ (.*?)\\ of\\ (.*?)\$'),
        'पृष्ठ __ARG0__ का __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Pain\\ severity:\\ (.*?)\\ /\\ 10\$'),
        'दर्द की तीव्रता: __ARG0__ / 10',
      ),
      _LocalizedPattern(RegExp('^Period\\ (.*?)\$'), 'अवधि __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^Please\\ confirm\\ AI\\ processing\\ consent\\ before\\ requesting\\ your\\ (.*?)\\ plan\\.\$',
        ),
        'कृपया अपना __ARG0__ प्लान अनुरोध करने से पहले एआई प्रोसेसिंग के लिए सहमति की पुष्टि करें।',
      ),
      _LocalizedPattern(RegExp('^Poor\\ \\((.*?)%\\)\$'), 'गरीब (__ARG0__%)'),
      _LocalizedPattern(
        RegExp('^PushService\\ init\\ error:\\ (.*?)\$'),
        'PushService आरंभ करने में त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Rank\\ \\#(.*?)\$'), 'रैंक #__ARG0__'),
      _LocalizedPattern(RegExp('^Rate\\ (.*?)\$'), 'दर __ARG0__'),
      _LocalizedPattern(
        RegExp('^Recent\\ activity\\.\\ (.*?)\\ at\\ (.*?)\\.\\ (.*?)\\.\$'),
        'हाल की गतिविधि। __ARG0__ पर __ARG1__। __ARG2__।',
      ),
      _LocalizedPattern(
        RegExp('^Remove\\ (.*?)\\ from\\ emergency\\ contacts\\?\$'),
        'आपातकालीन संपर्कों से __ARG0__ को हटाएँ?',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ Login\\ Code\\ API\\ error:\\ (.*?)\$'),
        'लॉगिन कोड अनुरोध API त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ failed\\ \\((.*?)\\)\$'),
        'अनुरोध विफल (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ your\\ (.*?)\$'),
        'अपने __ARG0__ का अनुरोध करें',
      ),
      _LocalizedPattern(
        RegExp(
          '^Requesting\\ health\\ authorization\\ for\\ (.*?)\\ supported\\ types\\.\$',
        ),
        '__ARG0__ समर्थित प्रकारों के लिए स्वास्थ्य प्राधिकरण का अनुरोध किया जा रहा है।',
      ),
      _LocalizedPattern(
        RegExp('^Reset\\ Password\\ API\\ error:\\ (.*?)\$'),
        'पासवर्ड रीसेट API त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Response\\ Body:\\ (.*?)\$'),
        'प्रतिक्रिया निकाय: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Resting:\\ (.*?)(.*?)\$'),
        'विश्राम: __ARG0____ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Returning\\ cached\\ HealthData\\ \\(age:\\ (.*?)s\\)\$'),
        'कैश्ड हेल्थडेटा लौटाया जा रहा है (आयु: __ARG0__s)',
      ),
      _LocalizedPattern(
        RegExp(
          '^Returning\\ cached\\ daily\\ health\\ records\\ \\(age:\\ (.*?)s\\)\$',
        ),
        'कैश्ड दैनिक स्वास्थ्य रिकॉर्ड लौटाना (आयु: __ARG0__s)',
      ),
      _LocalizedPattern(
        RegExp('^SOS\\ location\\ capture\\ failed:\\ (.*?)\$'),
        'SOS लोकेशन कैप्चर विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Scanner\\-origin\\ monitor\\ unavailable:\\ (.*?)\$'),
        'स्कैनर-ओरिजिन मॉनिटर अनुपलब्ध: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Session\\ length:\\ (.*?)\\ min\$'),
        'सत्र की अवधि: __ARG0__ मिनट',
      ),
      _LocalizedPattern(RegExp('^Set\\ (.*?)\$'), '__ARG0__ सेट करें'),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ · __ARG1__ रिप्स सेट करें',
      ),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ · __ARG1__ रिप्स सेट करें',
      ),
      _LocalizedPattern(RegExp('^Set\\ (.*?)\$'), '__ARG0__ सेट करें'),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ · __ARG1__ रिप्स सेट करें',
      ),
      _LocalizedPattern(
        RegExp(
          '^Share\\ your\\ preferences\\.\\ Your\\ company\\ (.*?)\\ will\\ create\\ and\\ approve\\ the\\ plan\\ before\\ it\\ appears\\ here\\.\$',
        ),
        'अपनी प्राथमिकताएं साझा करें। आपकी कंपनी __ARG0__ योजना बनाएगी और उसे यहां प्रदर्शित होने से पहले अनुमोदित करेगी।',
      ),
      _LocalizedPattern(
        RegExp('^SignUp\\ API\\ error:\\ (.*?)\$'),
        'साइन अप एपीआई त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Skipped\\ API\\ override:\\ local\\ pref\\ already\\ exists:\\ (.*?)\\ ml\$',
        ),
        'API ओवरराइड को छोड़ दिया गया: स्थानीय प्राथमिकता पहले से मौजूद है: __ARG0__ ml',
      ),
      _LocalizedPattern(RegExp('^Sleep:\\ (.*?)%\$'), 'नींद: __ARG0__%'),
      _LocalizedPattern(
        RegExp('^Slot\\ booked\\ at\\ (.*?)\\.\$'),
        '__ARG0__ पर स्लॉट बुक किया गया।',
      ),
      _LocalizedPattern(
        RegExp('^Social\\ Login\\ API\\ error:\\ (.*?)\$'),
        'सोशल लॉगिन एपीआई त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Source:\\ (.*?)\\\$\\{report\\.memberCorrected\\ \\?\$'),
        'स्रोत: __ARG0__\${report.memberCorrected ?',
      ),
      _LocalizedPattern(
        RegExp('^Splash\\ initialization\\ error:\\ (.*?)\$'),
        'स्पलैश आरंभीकरण त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Splash\\ token\\ refresh\\ network\\ error\\ \\(offline\\ mode\\):\\ (.*?)\$',
        ),
        'स्प्लैश टोकन रीफ़्रेश नेटवर्क त्रुटि (ऑफ़लाइन मोड): __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Splash\\ token\\ verification\\ failed:\\ (.*?)\$'),
        'स्पलैश टोकन सत्यापन विफल: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Started\\ (.*?)\$'), '__ARG0__ शुरू हुआ'),
      _LocalizedPattern(
        RegExp('^Starts\\ in\\ (.*?)d\$'),
        '__ARG0__d में शुरू होता है',
      ),
      _LocalizedPattern(
        RegExp('^Stress\\ (.*?)/10\\ ·\\ (.*?)\$'),
        'तनाव __ARG0__/10 · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Submitting\\ profile\\ to\\ (.*?)\\ server\\.\\.\\.\$'),
        'प्रोफ़ाइल को __ARG0__ सर्वर पर सबमिट किया जा रहा है...',
      ),
      _LocalizedPattern(
        RegExp('^Suggested\\ slot\\ booked\\ at\\ (.*?)\\.\$'),
        '__ARG0__ पर सुझाया गया स्लॉट बुक किया गया।',
      ),
      _LocalizedPattern(
        RegExp('^Swipe\\ chart\\ to\\ see\\ all\\ (.*?)\\ points\$'),
        'सभी __ARG0__ बिंदुओं को देखने के लिए चार्ट को स्वाइप करें',
      ),
      _LocalizedPattern(
        RegExp('^Tap\\ to\\ expand\\ (.*?)\\ entries\$'),
        '__ARG0__ प्रविष्टियों को विस्तारित करने के लिए टैप करें',
      ),
      _LocalizedPattern(
        RegExp('^Target\\ muscles\\ today:\\ (.*?)\$'),
        'आज लक्षित मांसपेशियां: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Targets\\ ·\\ (.*?)\$'), 'लक्ष्य · __ARG0__'),
      _LocalizedPattern(RegExp('^Targets:\\ (.*?)\$'), 'लक्ष्य: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Tell\\ us\\ about\\ today’s\\ session\\ at\\ (.*?)\\.\$'),
        'हमें __ARG0__ पर आज के सत्र के बारे में बताएं।',
      ),
      _LocalizedPattern(
        RegExp(
          '^The\\ health\\ report\\ was\\ updated,\\ but\\ the\\ comparison\\ could\\ not\\ be\\ refreshed:\\ (.*?)\$',
        ),
        'स्वास्थ्य रिपोर्ट अपडेट कर दी गई, लेकिन तुलना को रीफ्रेश नहीं किया जा सका: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Theme\\ ·\\ (.*?)\$'), 'थीम · __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^This\\ notifies\\ (.*?)\'s\\ emergency\\ response\\ team\\ with\\ your\\ live\\ location\\ and\\ current\\ vitals\\.\\ Only\\ use\\ in\\ a\\ real\\ emergency\\.\$',
        ),
        'यह __ARG0__ की आपातकालीन प्रतिक्रिया टीम को आपकी लाइव लोकेशन और वर्तमान महत्वपूर्ण जानकारी की सूचना देता है। इसका उपयोग केवल वास्तविक आपात स्थिति में ही करें।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Three\\ consents\\ below\\ are\\ required\\ to\\ activate\\ your\\ (.*?)\\ membership\\.\\ Medical\\ Data\\ Sharing\\ is\\ optional\\.\$',
        ),
        'आपकी __ARG0__ सदस्यता को सक्रिय करने के लिए नीचे दी गई तीन सहमति आवश्यक हैं। चिकित्सा डेटा साझा करना वैकल्पिक है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^To\\ (.*?),\\ approve\\ the\\ required\\ facility\\ workout\\-data\\ sharing\\ setting\\.\$',
        ),
        '__ARG0__ को, आवश्यक सुविधा वर्कआउट-डेटा साझाकरण सेटिंग को अनुमोदित करें।',
      ),
      _LocalizedPattern(
        RegExp('^Today\\ nutrition\\ plan:\\ (.*?)\$'),
        'आज का पोषण योजना: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Today\\ workout\\ plan:\\ (.*?)\$'),
        'आज का वर्कआउट प्लान: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Today,\\ (.*?)\$'), 'आज, __ARG0__'),
      _LocalizedPattern(
        RegExp('^Token\\ Refresh\\ API\\ connection\\ error:\\ (.*?)\$'),
        'टोकन रीफ्रेश एपीआई कनेक्शन त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^URL:\\ (.*?)\$'), 'यूआरएल: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ check\\ health\\ service\\ status:\\ (.*?)\$'),
        'स्वास्थ्य सेवा की स्थिति की जाँच करने में असमर्थ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ connect\\ health\\ services:\\ (.*?)\$'),
        'स्वास्थ्य सेवाओं से जुड़ने में असमर्थ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ open\\ dialer\\ for\\ (.*?)\$'),
        '__ARG0__ के लिए डायलर खोलने में असमर्थ',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ refresh\\ Care\\ Programs:\\ (.*?)\$'),
        'केयर प्रोग्राम्स को रीफ़्रेश करने में असमर्थ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ refresh\\ unread\\ notifications:\\ (.*?)\$'),
        'अपठित सूचनाओं को रीफ़्रेश करने में असमर्थ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unsupported\\ HTTP\\ method\\ (.*?)\$'),
        'असमर्थित HTTP विधि __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Update\\ how\\ you\\ show\\ up\\ in\\ (.*?)\$'),
        '__ARG0__ में आप कैसे दिखाई देते हैं, इसे अपडेट करें',
      ),
      _LocalizedPattern(
        RegExp(
          '^Use\\ the\\ QR\\ displayed\\ at\\ the\\ facility\\ entrance\\ to\\ start\\ (.*?)\\.\$',
        ),
        'सुविधा के प्रवेश द्वार पर प्रदर्शित क्यूआर का उपयोग करके __ARG0__ प्रारंभ करें।',
      ),
      _LocalizedPattern(
        RegExp('^Verify\\ OTP\\ API\\ error:\\ (.*?)\$'),
        'OTP API त्रुटि सत्यापित करें: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^W(.*?)\$'), 'W__ARG0__'),
      _LocalizedPattern(
        RegExp('^Waiting\\ for\\ (.*?)\$'),
        '__ARG0__ का इंतज़ार है',
      ),
      _LocalizedPattern(
        RegExp('^Water\\ logged\\ locally:\\ (.*?)\\ ml\$'),
        'स्थानीय स्तर पर जलभराव: __ARG0__ मिलीलीटर',
      ),
      _LocalizedPattern(RegExp('^Week\\ (.*?)\$'), 'सप्ताह __ARG0__'),
      _LocalizedPattern(
        RegExp('^Week\\ (.*?)\\ of\\ (.*?)\$'),
        'सप्ताह __ARG0__ का __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ bridge\\ unavailable:\\ (.*?)\$'),
        'वर्कआउट बैकग्राउंड ब्रिज अनुपलब्ध: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ service\\ stop\\ failed:\\ (.*?)\$'),
        'वर्कआउट बैकग्राउंड सर्विस स्टॉप विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Workout\\ background\\ service\\ stop\\ unavailable:\\ (.*?)\$',
        ),
        'वर्कआउट बैकग्राउंड सर्विस बंद करने में असमर्थ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ service\\ unavailable:\\ (.*?)\$'),
        'वर्कआउट बैकग्राउंड सेवा अनुपलब्ध: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ feedback\\ request\\ failed\\ \\((.*?)\\)\$'),
        'वर्कआउट फीडबैक अनुरोध विफल (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ location\\ monitoring\\ error:\\ (.*?)\$'),
        'व्यायाम स्थल निगरानी त्रुटि: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ report\\ \\-\\ (.*?)\$'),
        'वर्कआउट रिपोर्ट - __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Workout\\ started\\.\\ Turn\\ on\\ Location\\ and\\ allow\\ it\\ for\\ (.*?)\\ to\\ receive\\ the\\ automatic\\ 2\\ km\\ checkout\\ reminder\\.\$',
        ),
        'व्यायाम शुरू हो गया है। लोकेशन चालू करें और __ARG0__ को स्वचालित 2 किमी चेकआउट रिमाइंडर प्राप्त करने की अनुमति दें।',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ hide\\ failed:\\ (.*?)\$'),
        'वर्कआउट टाइमर सरफेस हाइड विफल: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ hide\\ unavailable:\\ (.*?)\$'),
        'वर्कआउट टाइमर सरफेस हाइड अनुपलब्ध: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ unavailable:\\ (.*?)\$'),
        'वर्कआउट टाइमर सतह अनुपलब्ध: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Yesterday,\\ (.*?)\$'), 'कल, __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^You\\ already\\ booked\\ (.*?)\\ at\\ (.*?)\\ \\((.*?)\\)\\.\\ Choose\\ a\\ different\\ hour\\ or\\ cancel\\ that\\ booking\\ first\\.\$',
        ),
        'आपने पहले ही __ARG0__ को __ARG1__ (__ARG2__) पर बुक कर लिया है। कृपया कोई दूसरा समय चुनें या पहले उस बुकिंग को रद्द करें।',
      ),
      _LocalizedPattern(
        RegExp(
          '^You\\ are\\ checked\\ in\\ for\\ (.*?)\\.\\ Check\\ out\\ when\\ the\\ session\\ ends\\.\$',
        ),
        'आप __ARG0__ के लिए चेक इन हैं। सत्र समाप्त होने पर चेक आउट करें।',
      ),
      _LocalizedPattern(
        RegExp(
          '^You\\ started\\ at\\ (.*?)\\ over\\ an\\ hour\\ ago\\.\\ End\\ the\\ workout\\ session\\ when\\ you\\ are\\ done\\.\$',
        ),
        'आपने एक घंटे से भी अधिक समय पहले __ARG0__ पर शुरुआत की थी। पूरा होने पर वर्कआउट सेशन समाप्त करें।',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ (.*?)\\ Care\\ Program\\ progress\\ report\\.\$'),
        'आपके __ARG0__ केयर प्रोग्राम की प्रगति रिपोर्ट।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ has\\ been\\ notified\\ to\\ retry\\ your\\ plan\\.\$',
        ),
        'आपकी कंपनी __ARG0__ को अपना प्लान दोबारा आज़माने के लिए सूचित कर दिया गया है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ is\\ generating\\ a\\ draft\\ for\\ review\\.\$',
        ),
        'आपकी कंपनी __ARG0__ समीक्षा के लिए एक ड्राफ्ट तैयार कर रही है।',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ company\\ (.*?)\\ is\\ preparing\\ your\\ plan\\.\$'),
        'आपकी कंपनी __ARG0__ आपकी योजना तैयार कर रही है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ is\\ reviewing\\ your\\ plan\\ before\\ approval\\.\$',
        ),
        'आपकी कंपनी __ARG0__ अनुमोदन से पहले आपकी योजना की समीक्षा कर रही है।',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ completed\\ (.*?)\\ workout\\ report\\.\$'),
        'आपकी पूर्ण की गई __ARG0__ वर्कआउट रिपोर्ट।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ plan\\ renewal\\ is\\ being\\ prepared\\ by\\ your\\ company\\ (.*?)\\.\$',
        ),
        'आपकी कंपनी __ARG0__ द्वारा आपके प्लान के नवीनीकरण की तैयारी की जा रही है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ report\\ is\\ saved\\.\\ Your\\ current\\ app\\ BMI\\ is\\ (.*?)\\.\$',
        ),
        'आपकी रिपोर्ट सहेज ली गई है। आपके ऐप का वर्तमान बीएमआई __ARG0__ है।',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ request\\ has\\ been\\ sent\\ to\\ your\\ company\\ (.*?)\\.\$',
        ),
        'आपका अनुरोध आपकी कंपनी __ARG0__ को भेज दिया गया है।',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ specialist\\-approved\\ (.*?)\\ plan\\.\$'),
        'आपके विशेषज्ञ द्वारा अनुमोदित __ARG0__ योजना।',
      ),
      _LocalizedPattern(RegExp('^alert\\-(.*?)\$'), 'अलर्ट-__ARG0__'),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)\$'),
        'औसत / लक्ष्य __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)h\$'),
        'औसत / लक्ष्य __ARG0__h',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)\$'),
        'औसत / लक्ष्य __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)ml\$'),
        'औसत / लक्ष्य __ARG0__ml',
      ),
      _LocalizedPattern(
        RegExp('^care\\-program\\-progress\\-(.*?)\\.pdf\$'),
        'care-program-progress-__ARG0__.pdf',
      ),
      _LocalizedPattern(RegExp('^ecg\\-(.*?)\$'), 'ईसीजी-__एआरजी0__'),
      _LocalizedPattern(RegExp('^exercise\\-(.*?)\$'), 'व्यायाम-__ARG0__'),
      _LocalizedPattern(RegExp('^extra\\-(.*?)\$'), 'अतिरिक्त-__ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^health\\.installHealthConnect\\ failed,\\ falling\\ back:\\ (.*?)\$',
        ),
        'health.installHealthConnect विफल रहा, वापस आ रहा है: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^metric:(.*?):(.*?)\$'),
        'मीट्रिक:__ARG0__:__ARG1__',
      ),
      _LocalizedPattern(RegExp('^of\\ (.*?)\\ pts\$'), '__ARG0__ अंक'),
      _LocalizedPattern(
        RegExp('^session_exclusion:(.*?)\$'),
        'सत्र_बहिष्करण:__ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^session_type:(.*?)\$'),
        'सत्र_प्रकार:__ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^\\}(.*?)\\ vs\\ previous\\ 7\\ days\$'),
        '}__ARG0__ बनाम पिछले 7 दिन',
      ),
      _LocalizedPattern(RegExp('^\\}(.*?)\\ (.*?)\$'), '}__ARG0__ __ARG1__'),
      _LocalizedPattern(
        RegExp('^·\\ (.*?)/(.*?)\\ extra\$'),
        '· __ARG0__/__ARG1__ अतिरिक्त',
      ),
      _LocalizedPattern(
        RegExp(
          '^✅\\ Dashboard\\ synced\\ —\\ daily\\ steps:\\ (.*?),\\ weekly\\ average\\ steps:\\ (.*?),\\ score:\\ (.*?),\\ calories:\\ (.*?),\\ sleep:\\ (.*?),\\ water:\\ (.*?),\\ rewards:\\ (.*?),\\ challenges:\\ (.*?)\$',
        ),
        '✅ डैशबोर्ड सिंक्रनाइज़ हो गया है — दैनिक कदम: __ARG0__, साप्ताहिक औसत कदम: __ARG1__, स्कोर: __ARG2__, कैलोरी: __ARG3__, नींद: __ARG4__, पानी: __ARG5__, पुरस्कार: __ARG6__, चुनौतियाँ: __ARG7__',
      ),
      _LocalizedPattern(
        RegExp('^✅\\ GET\\ Dashboard\\ done\\ —\\ widgets\\ count:\\ (.*?)\$'),
        '✅ डैशबोर्ड का निर्माण पूरा हुआ — विजेट्स की संख्या: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^✅\\ Sync\\ POST\\ done\\ —\\ score:\\ (.*?),\\ water:\\ (.*?)\$',
        ),
        '✅ सिंक्रोनाइज़ेशन पोस्ट पूरा हुआ — स्कोर: __ARG0__, पानी: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^🌙\\ (.*?)h\$'), '🌙 __ARG0__h'),
      _LocalizedPattern(RegExp('^💧\\ (.*?)ml\$'), '💧 __ARG0__ml'),
      _LocalizedPattern(
        RegExp('^🔍\\ widgetsData\\ count:\\ (.*?),\\ titles:\\ (.*?)\$'),
        '🔍 विजेट डेटा गणना: __ARG0__, शीर्षक: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^🔥\\ (.*?)\$'), '🔥 __ARG0__'),
      _LocalizedPattern(RegExp('^🚶\\ (.*?)\$'), '🚶 __ARG0__'),
    ],
    'kn': [
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ exercise\\(s\\)\\ fully\\ completed\\.\\ You\\ can\\ still\\ check\\ out\\ if\\ the\\ checklist\\ is\\ incomplete\\.\$',
        ),
        '__ARG0__ ವ್ಯಾಯಾಮ(ಗಳು) ಸಂಪೂರ್ಣವಾಗಿ ಪೂರ್ಣಗೊಂಡಿದೆ. ಪರಿಶೀಲನಾಪಟ್ಟಿ ಅಪೂರ್ಣವಾಗಿದೆಯೇ ಎಂದು ನೀವು ಇನ್ನೂ ಪರಿಶೀಲಿಸಬಹುದು.',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ Pts\$'), '__ARG0__ ಅಂಕಗಳು'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ yrs\\ ·\\ (.*?)\$'),
        '__ARG0__ ವರ್ಷಗಳು · __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ಎಆರ್‌ಜಿ0____ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(
        RegExp('^(.*?)(.*?)(.*?)\$'),
        '__ARG0____ARG1____ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ measurements\\ compared\\ ·\\ (.*?)\\ changed\\ ·\\ (.*?)\\ unchanged\\\$\\{recordedOnce\\ ==\\ 0\\ \\?\$',
        ),
        '__ARG0__ ಅಳತೆಗಳನ್ನು ಹೋಲಿಸಲಾಗಿದೆ · __ARG1__ ಬದಲಾಗಿದೆ · __ARG2__ ಬದಲಾಗಿಲ್ಲ\${recordedOnce == 0 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\$'),
        '__ARG1__ ರಲ್ಲಿ __ARG0__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ •\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ • __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-DAY\\ SCHEDULE\$'),
        '__ARG0__-ದಿನದ ವೇಳಾಪಟ್ಟಿ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ weeks\$'), '__ARG0__ ವಾರಗಳು'),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?)\\ \\\$\\{local\\.hour\\ >=\\ 12\\ \\?\$'),
        '__ARG0__:__ARG1__ \${local.hour &gt;= 12 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ exercises\\ lined\\ up\$'),
        '__ARG0__ ವ್ಯಾಯಾಮಗಳನ್ನು ಸಾಲಾಗಿ ಇರಿಸಲಾಗಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ meals\\ planned\$'),
        '__ARG0__ ಊಟಗಳನ್ನು ಯೋಜಿಸಲಾಗಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ across\\ (.*?)\\ meals\$'),
        '__ARG1__ ಊಟಗಳಲ್ಲಿ __ARG0__ kcal',
      ),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ target\\.\\ Tap\\ to\\ locate\\ it\\ on\\ the\\ body\\ map\\.\$',
        ),
        '__ARG0__ ಗುರಿ. ಬಾಡಿ ಮ್ಯಾಪ್‌ನಲ್ಲಿ ಅದನ್ನು ಪತ್ತೆಹಚ್ಚಲು ಟ್ಯಾಪ್ ಮಾಡಿ.',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ view\$'), '__ARG0__ ವೀಕ್ಷಣೆ'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)\$'), '__ARG0__: __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?):\\ \\\$\\{metric\\.value\\ ==\\ null\\ \\?\$'),
        '__ARG0__: \${metric.value == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)/\$'), '__ARG0__/'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ logged\\ successfully!\$'),
        '__ARG0__ ಯಶಸ್ವಿಯಾಗಿ ಲಾಗಿನ್ ಆಗಿದೆ!',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ min\$'), '__ARG0__ ನಿಮಿಷ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ min\\ (.*?)\\ sec\$'),
        '__ARG0__ ನಿಮಿಷ __ARG1__ ಸೆಕೆಂಡು',
      ),
      _LocalizedPattern(RegExp('^(.*?):(.*?)\$'), '__ARG0__:__ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ Wellness\$'), '__ARG0__ ಸ್ವಾಸ್ಥ್ಯ'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ →\\ (.*?)\$'), '__ARG0__ → __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)%\\ done\$'), '__ARG0__% ಮುಗಿದಿದೆ'),
      _LocalizedPattern(RegExp('^(.*?)\\ pts\$'), '__ARG0__ ಅಂಕಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)/\$'), '__ARG0__/'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)(.*?)\$'),
        '__ARG0__ - __ARG1____ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ authentication\\ was\\ cancelled\\.\$'),
        '__ARG0__ ದೃಢೀಕರಣವನ್ನು ರದ್ದುಗೊಳಿಸಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ reps\$'), '__ARG0__ ಪ್ರತಿನಿಧಿಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ sec\$'), '__ARG0__ ಸೆಕೆಂಡ್'),
      _LocalizedPattern(RegExp('^(.*?)\\ sets\$'), '__ARG0__ ಸೆಟ್‌ಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs/day\$'), '__ARG0__ ಗಂಟೆಗಳು/ದಿನ'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal/day\$'), '__ARG0__ kcal/ದಿನಕ್ಕೆ'),
      _LocalizedPattern(RegExp('^(.*?)\\ ml/day\$'), '__ARG0__ ಮಿಲಿ/ದಿನಕ್ಕೆ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ total\\ steps\$'),
        '__ARG0__ ಒಟ್ಟು ಹಂತಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ targeted\\ \\\$\\{targetCount\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ ಗುರಿ \${targetCount == 1 ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{field\\.unit\\.isEmpty\\ \\?\$'),
        '__ARG0__\${field.unit.isEmpty ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)m\$'), '__ARG0__ಮೀ'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(RegExp('^(.*?)g\$'), '__ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\.mp4\$'),
        '__ARG0__/__ARG1__.mp4',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\.mp4\\.download\$'),
        '__ARG0__/__ARG1__.mp4.ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(
        RegExp('^(.*?)%\\ Target\\ Met\$'),
        '__ARG0__% ಗುರಿ ತಲುಪಲಾಗಿದೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)k\$'), '__ARG0__ಕೆ'),
      _LocalizedPattern(RegExp('^(.*?)\\ min\$'), '__ARG0__ ನಿಮಿಷ'),
      _LocalizedPattern(RegExp('^(.*?)k\$'), '__ARG0__ಕೆ'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ CARE\\ PROGRAMS\$'),
        '__ARG0__ ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ Wellness360\$'),
        '__ARG0__ ವೆಲ್ನೆಸ್360',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ health\\ report\$'),
        '__ARG0__ ಆರೋಗ್ಯ ವರದಿ',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\ is\\ connected\\ to\\ the\\ wrong\\ product\\ server\\.\$',
        ),
        '__ARG0__ ತಪ್ಪು ಉತ್ಪನ್ನ ಸರ್ವರ್‌ಗೆ ಸಂಪರ್ಕಗೊಂಡಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ monitoring\\ your\\ active\\ workout\\.\$'),
        '__ARG0__ ನಿಮ್ಮ ಸಕ್ರಿಯ ವ್ಯಾಯಾಮವನ್ನು ಮೇಲ್ವಿಚಾರಣೆ ಮಾಡುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ report\\ comparison\$'),
        '__ARG0__ ವರದಿ ಹೋಲಿಕೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-health\\-report\\-(.*?)\\.pdf\$'),
        '__ARG0__-ಆರೋಗ್ಯ-ವರದಿ-__ARG1__.pdf',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-report\\-comparison\\-(.*?)\\.pdf\$'),
        '__ARG0__-ವರದಿ-ಹೋಲಿಕೆ-__ARG1__.pdf',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ \\#Wellness360\$'),
        '__ARG0__ · #ಆರೋಗ್ಯ360',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ changed\$'), '__ARG0__ ಬದಲಾಗಿದೆ'),
      _LocalizedPattern(RegExp('^(.*?)\\ compared\$'), '__ARG0__ ಹೋಲಿಸಲಾಗಿದೆ'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{_comparison\\.newerReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${_comparison.newerReport.bmiBand == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{_comparison\\.olderReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${_comparison.olderReport.bmiBand == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ recorded\\ once\$'),
        '__ARG0__ ಒಮ್ಮೆ ರೆಕಾರ್ಡ್ ಮಾಡಲಾಗಿದೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ unchanged\$'), '__ARG0__ ಬದಲಾಗಿಲ್ಲ'),
      _LocalizedPattern(
        RegExp('^(.*?)/medifit_body_composition_(.*?)_(.*?)\\.png\$'),
        '__ARG0__/medifit_body_composition___ARG1_____ARG2__.png',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ (.*?)\\ min\$'),
        '__ARG0__ · __ARG1__ ನಿಮಿಷ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Duration\\ not\\ recorded\$'),
        '__ARG0__ · ಅವಧಿ ದಾಖಲಾಗಿಲ್ಲ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{_comparison\\.elapsedDays\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${_comparison.elapsedDays == 1 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ml\\ /\\ (.*?)\\ ml\$'),
        '__ARG0__ ಮಿಲಿ / __ARG1__ ಮಿಲಿ',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ →\\ (.*?)\$'), '__ARG0__ → __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ to\\ (.*?)\$'),
        '__ARG0__ ರಿಂದ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0__ - __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ –\\ \\\$\\{p\\.endsOn\\ ==\\ null\\ \\?\$'),
        '__ARG0__ – \${p.endsOn == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ –\\ (.*?)\$'), '__ARG0__ – __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs\$'), '__ARG0__ ಗಂಟೆಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ಎಆರ್‌ಜಿ0__/__ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{program\\.completedAt\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${program.completedAt == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{program\\.completionSummary\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${program.completionSummary == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{comparison\\.newerReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${comparison.newerReport.bmiBand == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\\$\\{comparison\\.olderReport\\.bmiBand\\ ==\\ null\\ \\?\$',
        ),
        '__ARG0__\${comparison.olderReport.bmiBand == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal/day\$'), '__ARG0__ kcal/ದಿನಕ್ಕೆ'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(RegExp('^(.*?)\\ years\$'), '__ARG0__ ವರ್ಷಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{report\\.bmiBand\\ ==\\ null\\ \\?\$'),
        '__ARG0__\${report.bmiBand == ಶೂನ್ಯ ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0__ - __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\-\\\$\\{_selectedDob\\.month\\.toString\\(\\)\\.padLeft\\(2,\$',
        ),
        '__ARG0__-\${_selectedDob.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(RegExp('^(.*?)/10\$'), '__ಎಆರ್‌ಜಿ0__/10'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)/(.*?)\$'),
        '__ARG0__ __ARG1__/__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ACTIVE\$'), '__ARG0__ ಸಕ್ರಿಯ'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ ·\\ (.*?)g\\ protein\$'),
        '__ARG0__ kcal · __ARG1__g ಪ್ರೋಟೀನ್',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(RegExp('^(.*?)\\ hrs\$'), '__ARG0__ ಗಂಟೆಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ml\$'), '__ARG0__ ಮಿಲಿ'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?):\\ (.*?)%\$'), '__ARG0__: __ARG1__%'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ burned\$'),
        '__ARG0__ kcal ಬರ್ನ್ ಮಾಡಲಾಗಿದೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ joined\$'), '__ARG0__ ಸೇರಿಕೊಂಡರು'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ participants\$'),
        '__ARG0__ ಭಾಗವಹಿಸುವವರು',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Goal:\\ (.*?)\$'),
        '__ARG0__ · ಗುರಿ: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{comparison\\.elapsedDays\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${comparison.elapsedDays == 1 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ metrics\\ ·\\ (.*?)\\ days\\ elapsed\$'),
        '__ARG0__ ಮೆಟ್ರಿಕ್ಸ್ · __ARG1__ ದಿನಗಳು ಕಳೆದಿವೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ available\\ in\\ your\\ history\\.\$'),
        '__ARG0__ ನಿಮ್ಮ ಇತಿಹಾಸದಲ್ಲಿ ಲಭ್ಯವಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ sets(.*?)\$'),
        '__ARG0__/__ARG1__ ಸೆಟ್‌ಗಳು__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ remains\\ active\$'),
        '__ARG0__ ಸಕ್ರಿಯವಾಗಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ /\\ (.*?)\\ ml\$'),
        '__ARG0__ / __ARG1__ ಮಿಲಿ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ cm\$'), '__ARG0__ ಸೆಂ.ಮೀ.'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ exercises\$'), '__ARG0__ ವ್ಯಾಯಾಮಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\\ meals\$'), '__ARG0__ ಊಟಗಳು'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(
        RegExp('^(.*?):\\ \\\$\\{hasWorkout\\ \\?\$'),
        '__ARG0__: \${ವ್ಯಾಯಾಮ ಮಾಡ್ತಾ ಇದ್ದೀರಾ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{day\\.month\\.toString\\(\\)\\.padLeft\\(2,\$'),
        '__ARG0__-\${day.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{dayFirst\\.group\\(2\\)!\\.padLeft\\(2,\$'),
        '__ARG0__-\${dayFirst.group(2)!.padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ days\\ left\$'),
        '__ARG0__ ದಿನಗಳು ಉಳಿದಿವೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)d\\ ago\$'), '__ARG0__ದಿನಗಳ ಹಿಂದೆ'),
      _LocalizedPattern(RegExp('^(.*?)h\\ ago\$'), '__ARG0__ಗಂ ಹಿಂದೆ'),
      _LocalizedPattern(RegExp('^(.*?)m\\ ago\$'), '__ARG0__ನಿ ಹಿಂದೆ'),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__ಗಂ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{e\\.message\\ \\?\\?\$'),
        '__ARG0__ \${ಇ.ಸಂದೇಶ ??',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ alerts\\ on\$'),
        '__ARG0__ ಎಚ್ಚರಿಕೆಗಳು ಆನ್ ಆಗಿವೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ exercises\\ completed\$'),
        '__ARG1__ ವ್ಯಾಯಾಮಗಳಲ್ಲಿ __ARG0__ ಪೂರ್ಣಗೊಂಡಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ assigned\\ sets\\ completed\$'),
        '__ARG1__ ರಲ್ಲಿ __ARG0__ ನಿಯೋಜಿಸಲಾದ ಸೆಟ್‌ಗಳು ಪೂರ್ಣಗೊಂಡಿವೆ.',
      ),
      _LocalizedPattern(RegExp('^(.*?)%\$'), '__ARG0__%'),
      _LocalizedPattern(
        RegExp('^(.*?)%\\ complete\$'),
        '__ARG0__% ಪೂರ್ಣಗೊಂಡಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ must\\ be\\ a\\ number\\.\$'),
        '__ARG0__ ಒಂದು ಸಂಖ್ಯೆಯಾಗಿರಬೇಕು.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\.download\$'),
        '__ARG0__.ಡೌನ್‌ಲೋಡ್ ಮಾಡಿ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)%\\ \\\$\\{percentage\\ >\\ 0\\ \\?\$'),
        '__ARG0__% \${ಶೇಕಡಾವಾರು &gt; 0 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ than\\ earlier\$'),
        '__ARG0__ __ARG1__ ಹಿಂದಿನದಕ್ಕಿಂತ',
      ),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__ಗಂ'),
      _LocalizedPattern(RegExp('^(.*?)h\\ (.*?)m\$'), '__ARG0__ಗಂ __ARG1__ಮೀ'),
      _LocalizedPattern(RegExp('^(.*?)\\ of\\ 5\$'), '__ARG0__ / 5'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{iso\\.group\\(2\\)!\\.padLeft\\(2,\$'),
        '__ARG0__-\${iso.group(2)!.padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0__ - __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ·\\ Published\\ (.*?)\$'),
        '__ARG0__ · ಪ್ರಕಟಿಸಲಾಗಿದೆ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ sets\$'),
        '__ARG0__/__ARG1__ ಸೆಟ್‌ಗಳು',
      ),
      _LocalizedPattern(
        RegExp(
          '^(.*?)/(.*?)\\ sets\\\$\\{item\\.reps\\ ==\\ null\\ \\|\\|\\ item\\.reps!\\.isEmpty\\ \\?\$',
        ),
        '__ARG0__/__ARG1__ ಸೆಟ್‌ಗಳು\${item.reps == ಶೂನ್ಯ || item.reps!.isEmpty ?',
      ),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ಎಆರ್‌ಜಿ0__/__ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)\\ extra\\ sets\$'),
        '__ARG0__/__ARG1__ ಹೆಚ್ಚುವರಿ ಸೆಟ್‌ಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\-\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0__ - __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)/(.*?)\$'), '__ಎಆರ್‌ಜಿ0__/__ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ ml\\ logged\$'),
        '__ARG0__ ಮಿಲಿ ಲಾಗ್ ಮಾಡಲಾಗಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ to\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ ರಿಂದ __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\\$\\{metric\\.unit\\.trim\\(\\)\\.isEmpty\\ \\?\$'),
        '__ARG0__\${metric.unit.trim().ಖಾಲಿಯಾಗಿದೆಯೇ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):\\ (.*?)\\ to\\ (.*?)\\ (.*?)\$'),
        '__ARG0__: __ARG1__ ರಿಂದ __ARG2__ __ARG3__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?),\\ (.*?)\$'),
        '__ARG0__ __ARG1__, __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?),\\ (.*?)\$'),
        '__ARG0__ __ARG1__, __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)m\$'), '__ARG0__ಮೀ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-\\\$\\{month\\.toString\\(\\)\\.padLeft\\(2,\$'),
        '__ARG0__-\${month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal/day\$'), '__ARG0__ kcal/ದಿನಕ್ಕೆ'),
      _LocalizedPattern(RegExp('^(.*?)\\ days/week\$'), '__ARG0__ ದಿನಗಳು/ವಾರ'),
      _LocalizedPattern(RegExp('^(.*?)\\ meals/day\$'), '__ARG0__ ಊಟ/ದಿನ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ min/session\$'),
        '__ARG0__ ನಿಮಿಷ/ಅಧಿವೇಶನ',
      ),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ಎಆರ್‌ಜಿ0____ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__ಗಂ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ progress\\ \\-\\ (.*?)\$'),
        '__ARG0__ ಪ್ರಗತಿ - __ARG1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ •\\ (.*?)\$'), '__ARG0__ • __ARG1__'),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/(.*?)/(.*?)\\ (.*?):(.*?)\$'),
        '__ARG0__/__ARG1__/__ARG2__ __ARG3__:__ARG4__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ kcal\\ estimated\$'),
        '__ARG0__ kcal ಅಂದಾಜು',
      ),
      _LocalizedPattern(RegExp('^(.*?)s\\ rest\$'), '__ARG0__s ವಿಶ್ರಾಂತಿ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{results\\.length\\ ==\\ 1\\ \\?\$'),
        '__ARG0__ \${results.length == 1 ?',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ qualifying\\ days\$'),
        '__ARG0__ ಅರ್ಹತಾ ದಿನಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ verified\\ steps\$'),
        '__ARG0__ ಪರಿಶೀಲಿಸಿದ ಹಂತಗಳು',
      ),
      _LocalizedPattern(RegExp('^(.*?)h\$'), '__ARG0__ಗಂ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ places\\ left\$'),
        '__ARG0__ ಸ್ಥಳಗಳು ಉಳಿದಿವೆ',
      ),
      _LocalizedPattern(RegExp('^(.*?)\$'), '__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ expected\\ actions\$'),
        '__ARG1__ ನಿರೀಕ್ಷಿತ ಕ್ರಿಯೆಗಳಲ್ಲಿ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ of\\ (.*?)\\ expected\\ actions\\ completed\$'),
        '__ARG1__ ನಿರೀಕ್ಷಿತ ಕ್ರಿಯೆಗಳಲ್ಲಿ __ARG0__ ಪೂರ್ಣಗೊಂಡಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\-(.*?)\\-(.*?)\$'),
        '__ARG0__-__ARG1__-__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)/medifit_exercise_videos\$'),
        '__ARG0__/medifit_exercise_videos',
      ),
      _LocalizedPattern(
        RegExp('^(.*?):(.*?):(.*?)\$'),
        '__ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ bpm\$'), '__ARG0__ ಬಿಪಿಎಂ'),
      _LocalizedPattern(RegExp('^(.*?)\\ kcal\$'), '__ARG0__ ಕೆ.ಸಿ.ಎಲ್.'),
      _LocalizedPattern(RegExp('^(.*?)\\ ml\$'), '__ARG0__ ಮಿಲಿ'),
      _LocalizedPattern(
        RegExp('^(.*?)\\ session(.*?)\$'),
        '__ARG0__ ಅಧಿವೇಶನ__ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ \\\$\\{const\\ \\[\$'),
        '__ARG0__ \${const [',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\\ (.*?)\$'),
        '__ARG0__ __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ is\\ waiting\\ for\\ your\\ review\\.\$'),
        '__ARG0__ ನಿಮ್ಮ ವಿಮರ್ಶೆಗಾಗಿ ಕಾಯುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^(.*?)\\ (.*?)\$'),
        '__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ bpm\$'), '__ARG0__ ಬಿಪಿಎಂ'),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(
        RegExp(
          '^(.*?)\\-\\\$\\{value\\.month\\.toString\\(\\)\\.padLeft\\(2,\$',
        ),
        '__ARG0__-\${value.month.toString().padLeft(2,',
      ),
      _LocalizedPattern(
        RegExp('^(.*?),\\ (.*?)\\ (.*?)\$'),
        '__ARG0__, __ARG1__ __ARG2__',
      ),
      _LocalizedPattern(RegExp('^(.*?)\\ kg\$'), '__ARG0__ ಕೆಜಿ'),
      _LocalizedPattern(RegExp('^(.*?)\\ PROGRESS\$'), '__ARG0__ ಪ್ರಗತಿ'),
      _LocalizedPattern(RegExp('^(.*?)(.*?)\$'), '__ಎಆರ್‌ಜಿ0____ಎಆರ್‌ಜಿ1__'),
      _LocalizedPattern(RegExp('^(.*?)\\ ·\\ (.*?)\$'), '__ARG0__ · __ARG1__'),
      _LocalizedPattern(RegExp('^\\+(.*?)\\ ml\$'), '+__ARG0__ ಮಿಲಿ'),
      _LocalizedPattern(RegExp('^\\-\\ (.*?)\$'), '- __ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^/(.*?)\$'), '/__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(RegExp('^/(.*?)\$'), '/__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp(
          '^2026\\ (.*?)\\.\\ Secure\\ HIPAA\\ compliant\\ registration\\.\$',
        ),
        '2026 __ARG0__. ಸುರಕ್ಷಿತ HIPAA ಕಂಪ್ಲೈಂಟ್ ನೋಂದಣಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^================\\ (.*?)\\ API\\ REQUEST\\ ================\$',
        ),
        '================ __ARG0__ API ವಿನಂತಿ ==================',
      ),
      _LocalizedPattern(
        RegExp(
          '^================\\ (.*?)\\ API\\ RESPONSE\\ ================\$',
        ),
        '================ __ARG0__ API ಪ್ರತಿಕ್ರಿಯೆ ==================',
      ),
      _LocalizedPattern(
        RegExp('^AI\\ chat\\ error:\\ (.*?)\$'),
        'AI ಚಾಟ್ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^API\\ Error:\\ (.*?)\$'), 'API ದೋಷ: __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^API\\ Profile\\ load\\ failed,\\ falling\\ back\\ to\\ local:\\ (.*?)\$',
        ),
        'API ಪ್ರೊಫೈಲ್ ಲೋಡ್ ವಿಫಲವಾಗಿದೆ, ಸ್ಥಳೀಯಕ್ಕೆ ಹಿಂತಿರುಗುತ್ತಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Active:\\ (.*?)%\$'), 'ಸಕ್ರಿಯ: __ARG0__%'),
      _LocalizedPattern(
        RegExp('^App\\ BMI\\ (.*?)\$'),
        'ಅಪ್ಲಿಕೇಶನ್ BMI __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Apple\\ Authentication\\ error:\\ (.*?)\$'),
        'ಆಪಲ್ ದೃಢೀಕರಣ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Attendance\\ request\\ failed\\ \\((.*?)\\)\$'),
        'ಹಾಜರಾತಿ ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Authentication\\ failed:\\ (.*?)\$'),
        'ದೃಢೀಕರಣ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Avg\\ (.*?)\\ ml\\ ·\\ Total\\ (.*?)\\ ml\\ ·\\ (.*?)\\ points\$',
        ),
        'ಸರಾಸರಿ __ARG0__ ಮಿಲಿ · ಒಟ್ಟು __ARG1__ ಮಿಲಿ · __ARG2__ ಪಾಯಿಂಟ್‌ಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^Background\\ HealthKit\\ sync\\ failed:\\ (.*?)\$'),
        'ಹಿನ್ನೆಲೆ ಹೆಲ್ತ್‌ಕಿಟ್ ಸಿಂಕ್ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'ಧಾರಕ __ARG0__'),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'ಧಾರಕ __ARG0__'),
      _LocalizedPattern(RegExp('^Bearer\\ (.*?)\$'), 'ಧಾರಕ __ARG0__'),
      _LocalizedPattern(RegExp('^Body:\\ (.*?)\$'), 'ಮುಖ್ಯ ಭಾಗ: __ARG0__'),
      _LocalizedPattern(RegExp('^C\\ (.*?)g\$'), 'ಸಿ __ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(
        RegExp(
          '^Cannot\\ reach\\ the\\ API\\ at\\ (.*?)\\.\\ On\\ a\\ physical\\ phone\\ this\\ must\\ be\\ your\\ Mac\\ Wi\\-Fi\\ IP,\\ and\\ wellness\\-server\\ must\\ be\\ running\\.\$',
        ),
        '__ARG0__ ನಲ್ಲಿ API ಅನ್ನು ತಲುಪಲು ಸಾಧ್ಯವಿಲ್ಲ. ಭೌತಿಕ ಫೋನ್‌ನಲ್ಲಿ ಇದು ನಿಮ್ಮ Mac Wi-Fi IP ಆಗಿರಬೇಕು ಮತ್ತು wellness-server ಚಾಲನೆಯಲ್ಲಿರಬೇಕು.',
      ),
      _LocalizedPattern(
        RegExp('^Chat\\ history\\ bootstrap\\ failed:\\ (.*?)\$'),
        'ಚಾಟ್ ಇತಿಹಾಸ ಬೂಟ್‌ಸ್ಟ್ರ್ಯಾಪ್ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Checked\\ out\\ at\\ (.*?)\\.\\ Your\\ workout\\ report\\ is\\ being\\ prepared\\.\$',
        ),
        '__ARG0__ ನಲ್ಲಿ ಪರಿಶೀಲಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ವ್ಯಾಯಾಮ ವರದಿಯನ್ನು ಸಿದ್ಧಪಡಿಸಲಾಗುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ a\\ facility\\ and\\ (.*?)\\ slot\$'),
        'ಸೌಲಭ್ಯ ಮತ್ತು __ARG0__ ಸ್ಲಾಟ್ ಆಯ್ಕೆಮಾಡಿ',
      ),
      _LocalizedPattern(
        RegExp(
          '^Choose\\ a\\ facility\\ and\\ hourly\\ (.*?)\\ availability\$',
        ),
        'ಸೌಲಭ್ಯ ಮತ್ತು ಗಂಟೆಯ ಲಭ್ಯತೆಯನ್ನು ಆರಿಸಿ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ a\\ facility\\ for\\ (.*?)\$'),
        '__ARG0__ ಗಾಗಿ ಸೌಲಭ್ಯವನ್ನು ಆರಿಸಿ',
      ),
      _LocalizedPattern(
        RegExp('^Choose\\ how\\ (.*?)\\ looks\\ on\\ this\\ device\$'),
        'ಈ ಸಾಧನದಲ್ಲಿ __ARG0__ ಹೇಗೆ ಕಾಣುತ್ತದೆ ಎಂಬುದನ್ನು ಆರಿಸಿ',
      ),
      _LocalizedPattern(
        RegExp('^Completed\\ (.*?)\$'),
        'ಪೂರ್ಣಗೊಂಡಿದೆ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Connect\\ to\\ import\\ steps,\\ heart\\ rate,\\ sleep\\ metrics,\\ active\\ calories,\\ body\\ weight,\\ blood\\ pressure,\\ hydration,\\ and\\ nutrition\\ directly\\ from\\ (.*?)\\.\$',
        ),
        '__ARG0__ ನಿಂದ ನೇರವಾಗಿ ಹಂತಗಳು, ಹೃದಯ ಬಡಿತ, ನಿದ್ರೆಯ ಮಾಪನಗಳು, ಸಕ್ರಿಯ ಕ್ಯಾಲೋರಿಗಳು, ದೇಹದ ತೂಕ, ರಕ್ತದೊತ್ತಡ, ಜಲಸಂಚಯನ ಮತ್ತು ಪೋಷಣೆಯನ್ನು ಆಮದು ಮಾಡಿಕೊಳ್ಳಲು ಸಂಪರ್ಕಪಡಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ create\\ PDF:\\ (.*?)\$'),
        'PDF ಅನ್ನು ರಚಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ delete\\ the\\ comparison:\\ (.*?)\$'),
        'ಹೋಲಿಕೆಯನ್ನು ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ delete\\ the\\ report:\\ (.*?)\$'),
        'ವರದಿಯನ್ನು ಅಳಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ exercise\\ videos\\ \\((.*?)\\)\$'),
        'ವ್ಯಾಯಾಮ ವೀಡಿಯೊಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ privacy\\ settings:\\ (.*?)\$'),
        'ಗೌಪ್ಯತಾ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ load\\ reports:\\ (.*?)\$'),
        'ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ refresh\\ your\\ meal\\ tracker:\\ (.*?)\$'),
        'ನಿಮ್ಮ ಊಟ ಟ್ರ್ಯಾಕರ್ ಅನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ update\\ the\\ report:\\ (.*?)\$'),
        'ವರದಿಯನ್ನು ನವೀಕರಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ upload\\ the\\ report:\\ (.*?)\$'),
        'ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Could\\ not\\ verify\\ the\\ (.*?)\\ server\\.\$'),
        '__ARG0__ ಸರ್ವರ್ ಅನ್ನು ಪರಿಶೀಲಿಸಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ.',
      ),
      _LocalizedPattern(
        RegExp('^Couldn\'t\\ load\\ companies/facilities:\\ (.*?)\$'),
        'ಕಂಪನಿಗಳು/ಸೌಲಭ್ಯಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Couldn\'t\\ load\\ facilities\\ for\\ this\\ company:\\ (.*?)\$',
        ),
        'ಈ ಕಂಪನಿಗೆ ಸೌಲಭ್ಯಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Daily\\ Progress:\\ (.*?)%\$'),
        'ದೈನಂದಿನ ಪ್ರಗತಿ: __ARG0__%',
      ),
      _LocalizedPattern(
        RegExp('^Daily\\ calorie\\ target:\\ (.*?)\\ kcal\$'),
        'ದೈನಂದಿನ ಕ್ಯಾಲೋರಿ ಗುರಿ: __ARG0__ kcal',
      ),
      _LocalizedPattern(
        RegExp('^Dashboard\\ GET\\ Response:\\ (.*?)\$'),
        'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಪ್ರತಿಕ್ರಿಯೆ ಪಡೆಯಿರಿ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Days\\ per\\ week:\\ (.*?)\$'),
        'ವಾರದ ದಿನಗಳು: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Delete\\ “(.*?)”\\ and\\ all\\ of\\ its\\ messages\\?\\ This\\ cannot\\ be\\ undone\\.\$',
        ),
        '“__ARG0__” ಮತ್ತು ಅದರ ಎಲ್ಲಾ ಸಂದೇಶಗಳನ್ನು ಅಳಿಸುವುದೇ? ಇದನ್ನು ರದ್ದುಗೊಳಿಸಲು ಸಾಧ್ಯವಿಲ್ಲ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Detailed\\ (.*?)\\ anatomy\\ map\\.\\ (.*?)\\ is\\ focused\\ in\\ red\\.\$',
        ),
        'ವಿವರವಾದ __ARG0__ ಅಂಗರಚನಾಶಾಸ್ತ್ರ ನಕ್ಷೆ. __ARG1__ ಅನ್ನು ಕೆಂಪು ಬಣ್ಣದಲ್ಲಿ ಕೇಂದ್ರೀಕರಿಸಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Device\\ token\\ registration\\ error:\\ (.*?)\$'),
        'ಸಾಧನ ಟೋಕನ್ ನೋಂದಣಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Earlier\\ (.*?)\\ to\\ latest\\ (.*?)\$'),
        'ಹಿಂದಿನ __ARG0__ ರಿಂದ ಇತ್ತೀಚಿನ __ARG1__ ವರೆಗೆ',
      ),
      _LocalizedPattern(
        RegExp('^Earlier\\ ·\\ (.*?)\$'),
        'ಹಿಂದಿನದು · __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Edit\\ (.*?)\$'), 'ಸಂಪಾದಿಸಿ __ARG0__'),
      _LocalizedPattern(
        RegExp('^Enter\\ a\\ value\\ between\\ (.*?)\\ and\\ (.*?)\\.\$'),
        '__ARG0__ ಮತ್ತು __ARG1__ ನಡುವಿನ ಮೌಲ್ಯವನ್ನು ನಮೂದಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ checking\\ health\\ permissions:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಅನುಮತಿಗಳನ್ನು ಪರಿಶೀಲಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ configuring\\ HealthService:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಸೇವೆಯನ್ನು ಕಾನ್ಫಿಗರ್ ಮಾಡುವಾಗ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ deleting\\ log:\\ (.*?)\$'),
        'ಲಾಗ್ ಅಳಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ disconnecting\\ Google\\ Sign\\-In:\\ (.*?)\$'),
        'Google ಸೈನ್-ಇನ್ ಸಂಪರ್ಕ ಕಡಿತಗೊಳಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ during\\ full\\ daily\\ records\\ fetch:\\ (.*?)\$'),
        'ಪೂರ್ಣ ದೈನಂದಿನ ದಾಖಲೆಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ Android\\ Health\\ Connect\\ status:\\ (.*?)\$',
        ),
        'Android Health Connect ಸ್ಥಿತಿಯನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ active\\ challenges\\ for\\ dashboard:\\ (.*?)\$',
        ),
        'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಸಕ್ರಿಯ ಸವಾಲುಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ health\\ data\\ in\\ batch:\\ (.*?)\$',
        ),
        'ಬ್ಯಾಚ್‌ನಲ್ಲಿ ದೈನಂದಿನ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ health\\ data\\ type\\ (.*?)\\ in\\ fallback:\\ (.*?)\$',
        ),
        'ಫಾಲ್‌ಬ್ಯಾಕ್‌ನಲ್ಲಿ ದೈನಂದಿನ ಆರೋಗ್ಯ ಡೇಟಾ ಪ್ರಕಾರ __ARG0__ ಅನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ fetching\\ daily\\ sleep\\ data\\ in\\ batch:\\ (.*?)\$',
        ),
        'ಬ್ಯಾಚ್‌ನಲ್ಲಿ ದೈನಂದಿನ ನಿದ್ರೆಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ for\\ period:\\ (.*?)\$'),
        'ಈ ಅವಧಿಗೆ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ in\\ batch:\\ (.*?)\$'),
        'ಬ್ಯಾಚ್‌ನಲ್ಲಿ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ health\\ data\\ type\\ (.*?):\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಡೇಟಾ ಪ್ರಕಾರ __ARG0__: __ARG1__ ಅನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ ಕಂಡುಬಂದಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ iOS\\ medical\\ data:\\ (.*?)\$'),
        'iOS ವೈದ್ಯಕೀಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ points\\ balance:\\ (.*?)\$'),
        'ಅಂಕಗಳ ಸಮತೋಲನವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ sleep\\ data:\\ (.*?)\$'),
        'ನಿದ್ರೆಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ today\'s\\ health\\ data:\\ (.*?)\$'),
        'ಇಂದಿನ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ today\'s\\ sleep\\ data:\\ (.*?)\$'),
        'ಇಂದಿನ ನಿದ್ರೆಯ ಡೇಟಾವನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ water\\ graph:\\ (.*?)\$'),
        'ನೀರಿನ ಗ್ರಾಫ್ ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ fetching\\ water\\ logs:\\ (.*?)\$'),
        'ನೀರಿನ ದಾಖಲೆಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ aggregated\\ steps:\\ (.*?)\$'),
        'ಒಟ್ಟುಗೂಡಿಸಿದ ಹಂತಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ steps\\ for\\ (.*?):\\ (.*?)\$'),
        '__ARG0__: __ARG1__ ಗಾಗಿ ಹಂತಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ getting\\ steps\\ for\\ today:\\ (.*?)\$'),
        'ಇವತ್ತಿನ ಹಂತಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ in\\ _fetchRealData\\ combined\\ flow:\\ (.*?)\$'),
        '_fetchRealData ಸಂಯೋಜಿತ ಹರಿವಿನಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ in\\ _syncAndRefreshDashboard\\ combined\\ flow:\\ (.*?)\$',
        ),
        '_syncAndRefreshDashboard ಸಂಯೋಜಿತ ಹರಿವಿನಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ joining\\ challenge:\\ (.*?)\$'),
        'ಸವಾಲಿಗೆ ಸೇರುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ challenges:\\ (.*?)\$'),
        'ಸವಾಲುಗಳನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ data:\\ (.*?)\$'),
        'ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ notification\\ settings:\\ (.*?)\$'),
        'ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ persistent\\ cache:\\ (.*?)\$'),
        'ನಿರಂತರ ಸಂಗ್ರಹವನ್ನು ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ loading\\ profile:\\ (.*?)\$'),
        'ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ logging\\ water\\ locally:\\ (.*?)\$'),
        'ಸ್ಥಳೀಯವಾಗಿ ನೀರನ್ನು ಲಾಗಿಂಗ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ processing\\ health\\ data\\ for\\ (.*?):\\ (.*?)\$'),
        '__ARG0__: __ARG1__ ಗಾಗಿ ಆರೋಗ್ಯ ಡೇಟಾವನ್ನು ಪ್ರಕ್ರಿಯೆಗೊಳಿಸುವಲ್ಲಿ ದೋಷ ಕಂಡುಬಂದಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ requesting\\ health\\ permissions:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಅನುಮತಿಗಳನ್ನು ವಿನಂತಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ requesting\\ iOS\\ medical\\ permissions:\\ (.*?)\$'),
        'iOS ವೈದ್ಯಕೀಯ ಅನುಮತಿಗಳನ್ನು ವಿನಂತಿಸುವಾಗ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ saving\\ persistent\\ cache:\\ (.*?)\$'),
        'ನಿರಂತರ ಸಂಗ್ರಹವನ್ನು ಉಳಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Error\\ syncing\\ custom\\ goals\\ to\\ backend\\ server:\\ (.*?)\$',
        ),
        'ಬ್ಯಾಕೆಂಡ್ ಸರ್ವರ್‌ಗೆ ಕಸ್ಟಮ್ ಗುರಿಗಳನ್ನು ಸಿಂಕ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ syncing\\ logged\\ water\\ to\\ backend:\\ (.*?)\$'),
        'ಲಾಗ್ ಮಾಡಲಾದ ನೀರನ್ನು ಬ್ಯಾಕೆಂಡ್‌ಗೆ ಸಿಂಕ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ syncing\\ manual\\ logged\\ water:\\ (.*?)\$'),
        'ಹಸ್ತಚಾಲಿತವಾಗಿ ಲಾಗ್ ಮಾಡಿದ ನೀರನ್ನು ಸಿಂಕ್ ಮಾಡುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ updating\\ log:\\ (.*?)\$'),
        'ಲಾಗ್ ನವೀಕರಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Error\\ updating\\ profile:\\ (.*?)\$'),
        'ಪ್ರೊಫೈಲ್ ನವೀಕರಿಸುವಲ್ಲಿ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Error:\\ (.*?)\$'), 'ದೋಷ: __ARG0__'),
      _LocalizedPattern(RegExp('^Exercise\\ (.*?)\$'), 'ವ್ಯಾಯಾಮ __ARG0__'),
      _LocalizedPattern(
        RegExp('^Extra\\ set\\ (.*?)\$'),
        'ಹೆಚ್ಚುವರಿ ಸೆಟ್ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Extra\\ set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        'ಹೆಚ್ಚುವರಿ ಸೆಟ್ __ARG0__ · __ARG1__ ಪುನರಾವರ್ತನೆಗಳು',
      ),
      _LocalizedPattern(RegExp('^F\\ (.*?)g\$'), 'ಎಫ್ __ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(
        RegExp('^Facility\\ feedback\\ request\\ failed\\ \\((.*?)\\)\$'),
        'ಸೌಲಭ್ಯ ಪ್ರತಿಕ್ರಿಯೆ ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Facility\\ request\\ failed\\ \\((.*?)\\)\$'),
        'ಸೌಲಭ್ಯ ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ add\\ nutrition\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ಪೌಷ್ಟಿಕಾಂಶ ಲಾಗ್ ಸೇರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ add\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ನೀರಿನ ಲಾಗ್ ಸೇರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ authenticate\\ with\\ (.*?):\\ (.*?)\$'),
        '__ARG0__: __ARG1__ ನೊಂದಿಗೆ ದೃಢೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ call\\ (.*?)\$'),
        '__ARG0__ ಗೆ ಕರೆ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ compare\\ reports:\\ (.*?)\\ (.*?)\$'),
        'ವರದಿಗಳನ್ನು ಹೋಲಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ connect\\ to\\ server:\\ (.*?)\$'),
        'ಸರ್ವರ್‌ಗೆ ಸಂಪರ್ಕಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ create\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS ಸಂಪರ್ಕವನ್ನು ರಚಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ delete\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS ಸಂಪರ್ಕವನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'ಹೋಲಿಕೆಯನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ delete\\ nutrition\\ log:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಪೌಷ್ಟಿಕಾಂಶ ಲಾಗ್ ಅನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ನೀರಿನ ಲಾಗ್ ಅನ್ನು ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ delete:\\ (.*?)\$'),
        'ಅಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ fetch\\ challenges:\\ (.*?)\$'),
        'ಸವಾಲುಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ fetch\\ daily\\ records\\ for\\ sync\\.\\ Proceeding\\ with\\ empty\\.\\ Error:\\ (.*?)\$',
        ),
        'ಸಿಂಕ್‌ಗಾಗಿ ದೈನಂದಿನ ದಾಖಲೆಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ. ಖಾಲಿಯಾಗಿ ಮುಂದುವರಿಯುತ್ತಿದೆ. ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ fetch\\ notification\\ settings\\ from\\ API,\\ loading\\ fallback\\ cache:\\ (.*?)\$',
        ),
        'API ನಿಂದ ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ಪಡೆಯುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ, ಫಾಲ್‌ಬ್ಯಾಕ್ ಸಂಗ್ರಹವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗುತ್ತಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ get\\ dashboard:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಪಡೆಯಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ join\\ challenge:\\ (.*?)\$'),
        'ಸವಾಲಿಗೆ ಸೇರಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ SOS\\ contacts:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'SOS ಸಂಪರ್ಕಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ SOS\\ data:\\ (.*?)\$'),
        'SOS ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ challenges\\ from\\ server\\ \\((.*?)\\)\$',
        ),
        'ಸರ್ವರ್‌ನಿಂದ ಸವಾಲುಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'ಹೋಲಿಕೆ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ comparisons:\\ (.*?)\\ (.*?)\$'),
        'ಹೋಲಿಕೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ correction\\ history:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ತಿದ್ದುಪಡಿ ಇತಿಹಾಸವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ emergency\\ numbers:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ತುರ್ತು ಸಂಖ್ಯೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ goals\\ from\\ server,\\ using\\ local\\ cache:\\ (.*?)\$',
        ),
        'ಸ್ಥಳೀಯ ಸಂಗ್ರಹವನ್ನು ಬಳಸಿಕೊಂಡು ಸರ್ವರ್‌ನಿಂದ ಗುರಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ goals:\\ (.*?)\$'),
        'ಗುರಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ graph\\ data:\\ (.*?)\$'),
        'ಗ್ರಾಫ್ ಡೇಟಾವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ health\\ reports:\\ (.*?)\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ವರದಿಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ mood\\ check\\-ins:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಮನಸ್ಥಿತಿ ಪರಿಶೀಲನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ notifications:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ಅಧಿಸೂಚನೆಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ nutrition\\ logs:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಪೌಷ್ಟಿಕಾಂಶ ಲಾಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ load\\ today\'s\\ nutrition\\ totals:\\ (.*?)\$',
        ),
        'ಇಂದಿನ ಪೌಷ್ಟಿಕಾಂಶದ ಮೊತ್ತವನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ user\\ profile:\\ (.*?)\$'),
        'ಬಳಕೆದಾರ ಪ್ರೊಫೈಲ್ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ water\\ graph:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ನೀರಿನ ಗ್ರಾಫ್ ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ load\\ water\\ logs:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ನೀರಿನ ಲಾಗ್‌ಗಳನ್ನು ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ mark\\ notification\\ read:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಅಧಿಸೂಚನೆಯನ್ನು ಓದಲಾಗಿದೆ ಎಂದು ಗುರುತಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ migrate\\ health\\ connection\\ status:\\ (.*?)\$',
        ),
        'ಆರೋಗ್ಯ ಸಂಪರ್ಕ ಸ್ಥಿತಿಯನ್ನು ಸ್ಥಳಾಂತರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ persist\\ health\\ connection\\ status:\\ (.*?)\$',
        ),
        'ಆರೋಗ್ಯ ಸಂಪರ್ಕ ಸ್ಥಿತಿಯನ್ನು ಮುಂದುವರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ register\\ device\\ token:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಸಾಧನ ಟೋಕನ್ ನೋಂದಾಯಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ save\\ correction:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ತಿದ್ದುಪಡಿಯನ್ನು ಉಳಿಸುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ submit\\ enrolment\\ to\\ server:\\ (.*?)\$'),
        'ಸರ್ವರ್‌ಗೆ ನೋಂದಣಿಯನ್ನು ಸಲ್ಲಿಸುವಲ್ಲಿ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ submit\\ mood\\ check\\-in:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'ಮನಸ್ಥಿತಿ ಪರಿಶೀಲನೆಯನ್ನು ಸಲ್ಲಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ sync\\ dashboard:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಸಿಂಕ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ sync\\ water\\ log:\\ (.*?)\$'),
        'ನೀರಿನ ಲಾಗ್ ಅನ್ನು ಸಿಂಕ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ trigger\\ SOS:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'SOS ಅನ್ನು ಪ್ರಚೋದಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ undo\\ correction:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ತಿದ್ದುಪಡಿಯನ್ನು ರದ್ದುಗೊಳಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ update\\ SOS\\ contact:\\ (.*?)\\ \\-\\ (.*?)\$',
        ),
        'SOS ಸಂಪರ್ಕವನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ comparison:\\ (.*?)\\ (.*?)\$'),
        'ಹೋಲಿಕೆಯನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Failed\\ to\\ update\\ notification\\ setting\\ on\\ API:\\ (.*?)\$',
        ),
        'API ನಲ್ಲಿ ಅಧಿಸೂಚನೆ ಸೆಟ್ಟಿಂಗ್ ಅನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ profile:\\ (.*?)\$'),
        'ಪ್ರೊಫೈಲ್ ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ settings:\\ (.*?)\$'),
        'ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ user\\ profile:\\ (.*?)\$'),
        'ಬಳಕೆದಾರರ ಪ್ರೊಫೈಲ್ ಅನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update\\ water\\ log:\\ (.*?)\\ \\-\\ (.*?)\$'),
        'ನೀರಿನ ಲಾಗ್ ಅನ್ನು ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ - __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ update:\\ (.*?)\$'),
        'ನವೀಕರಿಸಲು ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Failed\\ to\\ upload\\ health\\ report:\\ (.*?)\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ಅಪ್‌ಲೋಡ್ ಮಾಡಲು ವಿಫಲವಾಗಿದೆ: __ARG0__ __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Fair\\ \\((.*?)%\\)\$'),
        'ನ್ಯಾಯೋಚಿತ (__ARG0__%)',
      ),
      _LocalizedPattern(
        RegExp('^Feeling:\\ (.*?)\\ ·\\ Progress:\\ (.*?)\$'),
        'ಭಾವನೆ: __ARG0__ · ಪ್ರಗತಿ: __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^For\\ the\\ signed\\-in\\ (.*?)\\ member\$'),
        'ಸೈನ್ ಇನ್ ಮಾಡಿದ __ARG0__ ಸದಸ್ಯರಿಗೆ',
      ),
      _LocalizedPattern(
        RegExp(
          '^Force\\ updated\\ local\\ water\\ intake\\ cache\\ to:\\ (.*?)\\ ml\$',
        ),
        'ನವೀಕರಿಸಿದ ಸ್ಥಳೀಯ ನೀರಿನ ಸೇವನೆಯ ಸಂಗ್ರಹವನ್ನು ಇದಕ್ಕೆ ಒತ್ತಾಯಿಸಿ: __ARG0__ ಮಿಲಿ',
      ),
      _LocalizedPattern(
        RegExp('^Forgot\\ Password\\ API\\ error:\\ (.*?)\$'),
        'ಪಾಸ್‌ವರ್ಡ್ ಮರೆತಿರುವ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^General\\ error\\ during\\ health\\ data\\ fetching:\\ (.*?)\$',
        ),
        'ಆರೋಗ್ಯ ದತ್ತಾಂಶ ಪಡೆಯುವ ಸಮಯದಲ್ಲಿ ಸಾಮಾನ್ಯ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Get\\ (.*?)\\ plan\$'),
        '__ARG0__ ಯೋಜನೆಯನ್ನು ಪಡೆಯಿರಿ',
      ),
      _LocalizedPattern(
        RegExp('^Goal:\\ (.*?)\\ hrs\$'),
        'ಗುರಿ: __ARG0__ ಗಂಟೆಗಳು',
      ),
      _LocalizedPattern(RegExp('^Goal:\\ (.*?)\$'), 'ಗುರಿ: __ARG0__'),
      _LocalizedPattern(RegExp('^Goal:\\ (.*?)h\$'), 'ಗುರಿ: __ARG0__ಗಂ'),
      _LocalizedPattern(
        RegExp('^Good\\ \\((.*?)%\\)\$'),
        'ಒಳ್ಳೆಯದು (__ARG0__%)',
      ),
      _LocalizedPattern(
        RegExp('^Google\\ Authentication\\ error:\\ (.*?)\$'),
        'Google ದೃಢೀಕರಣ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Have\\ you\\ left\\ (.*?)\\?\$'),
        'ನೀವು __ARG0__ ಬಿಟ್ಟಿದ್ದೀರಾ?',
      ),
      _LocalizedPattern(
        RegExp('^Health\\ authorization\\ request\\ returned:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ದೃಢೀಕರಣ ವಿನಂತಿಯನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Health\\ report\\ ·\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ವರದಿ · __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ agree\\ to\\ (.*?)\'s\\ terms\\ of\\ service\\ and\\ program\\ participation\\ rules\\.\$',
        ),
        'ನಾನು __ARG0__ ನ ಸೇವಾ ನಿಯಮಗಳು ಮತ್ತು ಕಾರ್ಯಕ್ರಮದಲ್ಲಿ ಭಾಗವಹಿಸುವಿಕೆಯ ನಿಯಮಗಳನ್ನು ಒಪ್ಪುತ್ತೇನೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ (.*?)\\ collecting\\ my\\ wearable/health\\ metrics\\ \\(steps,\\ sleep,\\ heart\\ rate\\)\\ to\\ power\\ my\\ wellness\\ dashboard\\.\$',
        ),
        'ನನ್ನ ಕ್ಷೇಮ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್‌ಗೆ ಶಕ್ತಿ ತುಂಬಲು ನನ್ನ ಧರಿಸಬಹುದಾದ/ಆರೋಗ್ಯ ಮೆಟ್ರಿಕ್‌ಗಳನ್ನು (ಹೆಜ್ಜೆಗಳು, ನಿದ್ರೆ, ಹೃದಯ ಬಡಿತ) ಸಂಗ್ರಹಿಸಲು ನಾನು __ARG0__ ಗೆ ಸಮ್ಮತಿಸುತ್ತೇನೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ AI\\ processing\\ for\\ my\\ (.*?)\\ plan\$',
        ),
        'ನನ್ನ __ARG0__ ಯೋಜನೆಗೆ AI ಪ್ರಕ್ರಿಯೆಗೆ ನಾನು ಸಮ್ಮತಿಸುತ್ತೇನೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^I\\ consent\\ to\\ sharing\\ relevant\\ medical\\ assessment\\ answers\\ with\\ (.*?)\'s\\ clinical\\ staff\\ for\\ clearance\\ review,\\ where\\ applicable\\.\$',
        ),
        'ಅನ್ವಯವಾಗುವಲ್ಲಿ, ಕ್ಲಿಯರೆನ್ಸ್ ಪರಿಶೀಲನೆಗಾಗಿ __ARG0__ ನ ಕ್ಲಿನಿಕಲ್ ಸಿಬ್ಬಂದಿಯೊಂದಿಗೆ ಸಂಬಂಧಿತ ವೈದ್ಯಕೀಯ ಮೌಲ್ಯಮಾಪನ ಉತ್ತರಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಲು ನಾನು ಸಮ್ಮತಿಸುತ್ತೇನೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Initialized\\ water\\ intake\\ from\\ API:\\ (.*?)\\ ml\$'),
        'API ನಿಂದ ಪ್ರಾರಂಭಿಕ ನೀರಿನ ಸೇವನೆ: __ARG0__ ಮಿಲಿ',
      ),
      _LocalizedPattern(
        RegExp('^Issue\\ assigned\\ to\\ (.*?)\\.\$'),
        '__ARG0__ ಗೆ ಸಂಚಿಕೆಯನ್ನು ನಿಯೋಜಿಸಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Joined\\ (.*?)\\ challenge!\$'),
        '__ARG0__ ಸವಾಲಿಗೆ ಸೇರಿದ್ದೀರಿ!',
      ),
      _LocalizedPattern(
        RegExp('^Last\\ sync:\\ (.*?):(.*?):(.*?)\$'),
        'ಕೊನೆಯ ಸಿಂಕ್: __ARG0__:__ARG1__:__ARG2__',
      ),
      _LocalizedPattern(
        RegExp('^Latest\\ ·\\ (.*?)\$'),
        'ಇತ್ತೀಚಿನದು · __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Loaded\\ persistent\\ HealthData\\ cache\\ \\(timestamp:\\ (.*?)\\)\$',
        ),
        'ನಿರಂತರ HealthData ಸಂಗ್ರಹವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಿದೆ (ಸಮಯಸ್ಟ್ಯಾಂಪ್: __ARG0__)',
      ),
      _LocalizedPattern(
        RegExp(
          '^Loaded\\ persistent\\ daily\\ records\\ cache\\ \\(timestamp:\\ (.*?)\\)\$',
        ),
        'ನಿರಂತರ ದೈನಂದಿನ ದಾಖಲೆಗಳ ಸಂಗ್ರಹವನ್ನು ಲೋಡ್ ಮಾಡಲಾಗಿದೆ (ಸಮಯಸ್ಟ್ಯಾಂಪ್: __ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Log\\ (.*?)\\ Manually\$'),
        '__ARG0__ ಹಸ್ತಚಾಲಿತವಾಗಿ ಲಾಗ್ ಮಾಡಿ',
      ),
      _LocalizedPattern(
        RegExp('^Logged\\ \\+(.*?)\\ ml\\ of\\ water!\$'),
        'ಲಾಗ್ ಮಾಡಲಾಗಿದೆ +__ARG0__ ಮಿಲಿ ನೀರು!',
      ),
      _LocalizedPattern(
        RegExp('^Login\\ API\\ error:\\ (.*?)\$'),
        'ಲಾಗಿನ್ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Login\\ With\\ Code\\ API\\ error:\\ (.*?)\$'),
        'ಕೋಡ್ API ದೋಷದೊಂದಿಗೆ ಲಾಗಿನ್ ಮಾಡಿ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Meals\\ per\\ day:\\ (.*?)\$'),
        'ದಿನಕ್ಕೆ ಊಟ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Measured\\ (.*?)\$'),
        'ಅಳತೆ ಮಾಡಲಾಗಿದೆ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Member\\ copy\\ \\-\\ generated\\ (.*?)\$'),
        'ಸದಸ್ಯರ ಪ್ರತಿ - ರಚಿಸಲಾಗಿದೆ __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Method:\\ (.*?)\$'), 'ವಿಧಾನ: __ARG0__'),
      _LocalizedPattern(RegExp('^Mind:\\ (.*?)%\$'), 'ಮನಸ್ಸು: __ARG0__%'),
      _LocalizedPattern(
        RegExp('^Mood\\ (.*?)/10\\ ·\\ (.*?)\$'),
        'ಮನಸ್ಥಿತಿ __ARG0__/10 · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Mood\\ check\\-in\\ history\\ error:\\ (.*?)\$'),
        'ಮೂಡ್ ಚೆಕ್-ಇನ್ ಇತಿಹಾಸ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Network\\ error:\\ (.*?)\$'),
        'ನೆಟ್‌ವರ್ಕ್ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Next\\ review:\\ (.*?)\$'),
        'ಮುಂದಿನ ವಿಮರ್ಶೆ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Next:\\ (.*?)\$'), 'ಮುಂದೆ: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Next:\\ (.*?)\\ ·\\ (.*?)\$'),
        'ಮುಂದೆ: __ARG0__ · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Notification\\ inbox\\ error:\\ (.*?)\$'),
        'ಅಧಿಸೂಚನೆ ಇನ್‌ಬಾಕ್ಸ್ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Nutrition:\\ (.*?)%\$'),
        'ಪೌಷ್ಟಿಕಾಂಶ: __ARG0__%',
      ),
      _LocalizedPattern(RegExp('^P\\ (.*?)g\$'), 'ಪಿ __ARG0__ಗ್ರಾಂ'),
      _LocalizedPattern(
        RegExp('^Page\\ (.*?)\\ of\\ (.*?)\$'),
        '__ARG1__ ರಲ್ಲಿ __ARG0__ ಪುಟ',
      ),
      _LocalizedPattern(
        RegExp('^Page\\ (.*?)\\ of\\ (.*?)\$'),
        '__ARG1__ ರಲ್ಲಿ __ARG0__ ಪುಟ',
      ),
      _LocalizedPattern(
        RegExp('^Pain\\ severity:\\ (.*?)\\ /\\ 10\$'),
        'ನೋವಿನ ತೀವ್ರತೆ: __ARG0__ / 10',
      ),
      _LocalizedPattern(RegExp('^Period\\ (.*?)\$'), 'ಅವಧಿ __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^Please\\ confirm\\ AI\\ processing\\ consent\\ before\\ requesting\\ your\\ (.*?)\\ plan\\.\$',
        ),
        'ನಿಮ್ಮ __ARG0__ ಯೋಜನೆಯನ್ನು ವಿನಂತಿಸುವ ಮೊದಲು ದಯವಿಟ್ಟು AI ಸಂಸ್ಕರಣಾ ಒಪ್ಪಿಗೆಯನ್ನು ದೃಢೀಕರಿಸಿ.',
      ),
      _LocalizedPattern(RegExp('^Poor\\ \\((.*?)%\\)\$'), 'ಕಳಪೆ (__ARG0__%)'),
      _LocalizedPattern(
        RegExp('^PushService\\ init\\ error:\\ (.*?)\$'),
        'ಪುಶ್‌ಸರ್ವಿಸ್ ಇನಿಟ್ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Rank\\ \\#(.*?)\$'), 'ಶ್ರೇಣಿ #__ARG0__'),
      _LocalizedPattern(RegExp('^Rate\\ (.*?)\$'), 'ದರ __ARG0__'),
      _LocalizedPattern(
        RegExp('^Recent\\ activity\\.\\ (.*?)\\ at\\ (.*?)\\.\\ (.*?)\\.\$'),
        'ಇತ್ತೀಚಿನ ಚಟುವಟಿಕೆ. __ARG0__ __ARG1__ ನಲ್ಲಿ. __ARG2__.',
      ),
      _LocalizedPattern(
        RegExp('^Remove\\ (.*?)\\ from\\ emergency\\ contacts\\?\$'),
        'ತುರ್ತು ಸಂಪರ್ಕಗಳಿಂದ __ARG0__ ಅನ್ನು ತೆಗೆದುಹಾಕುವುದೇ?',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ Login\\ Code\\ API\\ error:\\ (.*?)\$'),
        'ವಿನಂತಿ ಲಾಗಿನ್ ಕೋಡ್ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ failed\\ \\((.*?)\\)\$'),
        'ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Request\\ your\\ (.*?)\$'),
        'ನಿಮ್ಮ __ARG0__ ಅನ್ನು ವಿನಂತಿಸಿ',
      ),
      _LocalizedPattern(
        RegExp(
          '^Requesting\\ health\\ authorization\\ for\\ (.*?)\\ supported\\ types\\.\$',
        ),
        '__ARG0__ ಬೆಂಬಲಿತ ಪ್ರಕಾರಗಳಿಗೆ ಆರೋಗ್ಯ ದೃಢೀಕರಣವನ್ನು ವಿನಂತಿಸಲಾಗುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Reset\\ Password\\ API\\ error:\\ (.*?)\$'),
        'ಪಾಸ್‌ವರ್ಡ್ ಮರುಹೊಂದಿಸುವ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Response\\ Body:\\ (.*?)\$'),
        'ಪ್ರತಿಕ್ರಿಯೆ ಮುಖ್ಯಭಾಗ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Resting:\\ (.*?)(.*?)\$'),
        'ವಿಶ್ರಾಂತಿ: __ARG0____ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Returning\\ cached\\ HealthData\\ \\(age:\\ (.*?)s\\)\$'),
        'ಕ್ಯಾಶ್ ಮಾಡಲಾದ HealthData ಅನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ (ವಯಸ್ಸು: __ARG0__s)',
      ),
      _LocalizedPattern(
        RegExp(
          '^Returning\\ cached\\ daily\\ health\\ records\\ \\(age:\\ (.*?)s\\)\$',
        ),
        'ಸಂಗ್ರಹವಾಗಿರುವ ದೈನಂದಿನ ಆರೋಗ್ಯ ದಾಖಲೆಗಳನ್ನು ಹಿಂತಿರುಗಿಸಲಾಗುತ್ತಿದೆ (ವಯಸ್ಸು: __ARG0__s)',
      ),
      _LocalizedPattern(
        RegExp('^SOS\\ location\\ capture\\ failed:\\ (.*?)\$'),
        'SOS ಸ್ಥಳ ಸೆರೆಹಿಡಿಯುವಿಕೆ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Scanner\\-origin\\ monitor\\ unavailable:\\ (.*?)\$'),
        'ಸ್ಕ್ಯಾನರ್-ಮೂಲದ ಮಾನಿಟರ್ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Session\\ length:\\ (.*?)\\ min\$'),
        'ಅವಧಿಯ ಅವಧಿ: __ARG0__ ನಿಮಿಷ',
      ),
      _LocalizedPattern(RegExp('^Set\\ (.*?)\$'), '__ARG0__ ಹೊಂದಿಸಿ'),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ ಹೊಂದಿಸಿ · __ARG1__ ಪುನರಾವರ್ತನೆಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ ಹೊಂದಿಸಿ · __ARG1__ ಪುನರಾವರ್ತನೆಗಳು',
      ),
      _LocalizedPattern(RegExp('^Set\\ (.*?)\$'), '__ARG0__ ಹೊಂದಿಸಿ'),
      _LocalizedPattern(
        RegExp('^Set\\ (.*?)\\ ·\\ (.*?)\\ reps\$'),
        '__ARG0__ ಹೊಂದಿಸಿ · __ARG1__ ಪುನರಾವರ್ತನೆಗಳು',
      ),
      _LocalizedPattern(
        RegExp(
          '^Share\\ your\\ preferences\\.\\ Your\\ company\\ (.*?)\\ will\\ create\\ and\\ approve\\ the\\ plan\\ before\\ it\\ appears\\ here\\.\$',
        ),
        'ನಿಮ್ಮ ಆದ್ಯತೆಗಳನ್ನು ಹಂಚಿಕೊಳ್ಳಿ. ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ಇಲ್ಲಿ ಕಾಣಿಸಿಕೊಳ್ಳುವ ಮೊದಲು ಯೋಜನೆಯನ್ನು ರಚಿಸುತ್ತದೆ ಮತ್ತು ಅನುಮೋದಿಸುತ್ತದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^SignUp\\ API\\ error:\\ (.*?)\$'),
        'ಸೈನ್‌ಅಪ್ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Skipped\\ API\\ override:\\ local\\ pref\\ already\\ exists:\\ (.*?)\\ ml\$',
        ),
        'ಬಿಟ್ಟುಬಿಟ್ಟ API ಅತಿಕ್ರಮಣ: ಸ್ಥಳೀಯ ಆದ್ಯತೆ ಈಗಾಗಲೇ ಅಸ್ತಿತ್ವದಲ್ಲಿದೆ: __ARG0__ ಮಿಲಿ',
      ),
      _LocalizedPattern(RegExp('^Sleep:\\ (.*?)%\$'), 'ನಿದ್ರೆ: __ARG0__%'),
      _LocalizedPattern(
        RegExp('^Slot\\ booked\\ at\\ (.*?)\\.\$'),
        '__ARG0__ ನಲ್ಲಿ ಸ್ಲಾಟ್ ಬುಕ್ ಮಾಡಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Social\\ Login\\ API\\ error:\\ (.*?)\$'),
        'ಸಾಮಾಜಿಕ ಲಾಗಿನ್ API ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Source:\\ (.*?)\\\$\\{report\\.memberCorrected\\ \\?\$'),
        'ಮೂಲ: __ARG0__\${report.memberಸರಿಪಡಿಸಲಾಗಿದೆಯೇ?',
      ),
      _LocalizedPattern(
        RegExp('^Splash\\ initialization\\ error:\\ (.*?)\$'),
        'ಸ್ಪ್ಲಾಶ್ ಆರಂಭ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Splash\\ token\\ refresh\\ network\\ error\\ \\(offline\\ mode\\):\\ (.*?)\$',
        ),
        'ಸ್ಪ್ಲಾಶ್ ಟೋಕನ್ ರಿಫ್ರೆಶ್ ನೆಟ್‌ವರ್ಕ್ ದೋಷ (ಆಫ್‌ಲೈನ್ ಮೋಡ್): __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Splash\\ token\\ verification\\ failed:\\ (.*?)\$'),
        'ಸ್ಪ್ಲಾಶ್ ಟೋಕನ್ ಪರಿಶೀಲನೆ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Started\\ (.*?)\$'),
        'ಪ್ರಾರಂಭಿಸಲಾಗಿದೆ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Starts\\ in\\ (.*?)d\$'),
        '__ARG0__d ನಲ್ಲಿ ಪ್ರಾರಂಭವಾಗುತ್ತದೆ',
      ),
      _LocalizedPattern(
        RegExp('^Stress\\ (.*?)/10\\ ·\\ (.*?)\$'),
        'ಒತ್ತಡ __ARG0__/10 · __ARG1__',
      ),
      _LocalizedPattern(
        RegExp('^Submitting\\ profile\\ to\\ (.*?)\\ server\\.\\.\\.\$'),
        'ಪ್ರೊಫೈಲ್ ಅನ್ನು __ARG0__ ಸರ್ವರ್‌ಗೆ ಸಲ್ಲಿಸಲಾಗುತ್ತಿದೆ...',
      ),
      _LocalizedPattern(
        RegExp('^Suggested\\ slot\\ booked\\ at\\ (.*?)\\.\$'),
        'ಸೂಚಿಸಲಾದ ಸ್ಲಾಟ್ ಅನ್ನು __ARG0__ ನಲ್ಲಿ ಬುಕ್ ಮಾಡಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Swipe\\ chart\\ to\\ see\\ all\\ (.*?)\\ points\$'),
        'ಎಲ್ಲಾ __ARG0__ ಬಿಂದುಗಳನ್ನು ನೋಡಲು ಚಾರ್ಟ್ ಅನ್ನು ಸ್ವೈಪ್ ಮಾಡಿ',
      ),
      _LocalizedPattern(
        RegExp('^Tap\\ to\\ expand\\ (.*?)\\ entries\$'),
        '__ARG0__ ನಮೂದುಗಳನ್ನು ವಿಸ್ತರಿಸಲು ಟ್ಯಾಪ್ ಮಾಡಿ',
      ),
      _LocalizedPattern(
        RegExp('^Target\\ muscles\\ today:\\ (.*?)\$'),
        'ಇಂದು ಗುರಿ ಸ್ನಾಯುಗಳು: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Targets\\ ·\\ (.*?)\$'), 'ಗುರಿಗಳು · __ARG0__'),
      _LocalizedPattern(RegExp('^Targets:\\ (.*?)\$'), 'ಗುರಿಗಳು: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Tell\\ us\\ about\\ today’s\\ session\\ at\\ (.*?)\\.\$'),
        '__ARG0__ ನಲ್ಲಿ ಇಂದಿನ ಅಧಿವೇಶನದ ಬಗ್ಗೆ ನಮಗೆ ತಿಳಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^The\\ health\\ report\\ was\\ updated,\\ but\\ the\\ comparison\\ could\\ not\\ be\\ refreshed:\\ (.*?)\$',
        ),
        'ಆರೋಗ್ಯ ವರದಿಯನ್ನು ನವೀಕರಿಸಲಾಗಿದೆ, ಆದರೆ ಹೋಲಿಕೆಯನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Theme\\ ·\\ (.*?)\$'), 'ಥೀಮ್ · __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^This\\ notifies\\ (.*?)\'s\\ emergency\\ response\\ team\\ with\\ your\\ live\\ location\\ and\\ current\\ vitals\\.\\ Only\\ use\\ in\\ a\\ real\\ emergency\\.\$',
        ),
        'ಇದು __ARG0__ ನ ತುರ್ತು ಪ್ರತಿಕ್ರಿಯೆ ತಂಡಕ್ಕೆ ನಿಮ್ಮ ಲೈವ್ ಸ್ಥಳ ಮತ್ತು ಪ್ರಸ್ತುತ ಪ್ರಮುಖ ಮಾಹಿತಿಯೊಂದಿಗೆ ತಿಳಿಸುತ್ತದೆ. ನಿಜವಾದ ತುರ್ತು ಪರಿಸ್ಥಿತಿಯಲ್ಲಿ ಮಾತ್ರ ಬಳಸಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Three\\ consents\\ below\\ are\\ required\\ to\\ activate\\ your\\ (.*?)\\ membership\\.\\ Medical\\ Data\\ Sharing\\ is\\ optional\\.\$',
        ),
        'ನಿಮ್ಮ __ARG0__ ಸದಸ್ಯತ್ವವನ್ನು ಸಕ್ರಿಯಗೊಳಿಸಲು ಕೆಳಗಿನ ಮೂರು ಒಪ್ಪಿಗೆಗಳು ಅಗತ್ಯವಿದೆ. ವೈದ್ಯಕೀಯ ಡೇಟಾ ಹಂಚಿಕೆ ಐಚ್ಛಿಕವಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^To\\ (.*?),\\ approve\\ the\\ required\\ facility\\ workout\\-data\\ sharing\\ setting\\.\$',
        ),
        '__ARG0__ ಗೆ, ಅಗತ್ಯವಿರುವ ಸೌಲಭ್ಯದ ತಾಲೀಮು-ಡೇಟಾ ಹಂಚಿಕೆ ಸೆಟ್ಟಿಂಗ್ ಅನ್ನು ಅನುಮೋದಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Today\\ nutrition\\ plan:\\ (.*?)\$'),
        'ಇಂದಿನ ಪೌಷ್ಟಿಕಾಂಶ ಯೋಜನೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Today\\ workout\\ plan:\\ (.*?)\$'),
        'ಇಂದಿನ ವ್ಯಾಯಾಮ ಯೋಜನೆ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Today,\\ (.*?)\$'), 'ಇಂದು, __ARG0__'),
      _LocalizedPattern(
        RegExp('^Token\\ Refresh\\ API\\ connection\\ error:\\ (.*?)\$'),
        'ಟೋಕನ್ ರಿಫ್ರೆಶ್ API ಸಂಪರ್ಕ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^URL:\\ (.*?)\$'), 'URL: __ARG0__'),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ check\\ health\\ service\\ status:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಸೇವೆಯ ಸ್ಥಿತಿಯನ್ನು ಪರಿಶೀಲಿಸಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ connect\\ health\\ services:\\ (.*?)\$'),
        'ಆರೋಗ್ಯ ಸೇವೆಗಳನ್ನು ಸಂಪರ್ಕಿಸಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ open\\ dialer\\ for\\ (.*?)\$'),
        '__ARG0__ ಗಾಗಿ ಡಯಲರ್ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ.',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ refresh\\ Care\\ Programs:\\ (.*?)\$'),
        'ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unable\\ to\\ refresh\\ unread\\ notifications:\\ (.*?)\$'),
        'ಓದದಿರುವ ಅಧಿಸೂಚನೆಗಳನ್ನು ರಿಫ್ರೆಶ್ ಮಾಡಲು ಸಾಧ್ಯವಾಗುತ್ತಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Unsupported\\ HTTP\\ method\\ (.*?)\$'),
        'ಬೆಂಬಲವಿಲ್ಲದ HTTP ವಿಧಾನ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Update\\ how\\ you\\ show\\ up\\ in\\ (.*?)\$'),
        'ನೀವು __ARG0__ ನಲ್ಲಿ ಹೇಗೆ ಕಾಣಿಸಿಕೊಳ್ಳುತ್ತೀರಿ ಎಂಬುದನ್ನು ನವೀಕರಿಸಿ',
      ),
      _LocalizedPattern(
        RegExp(
          '^Use\\ the\\ QR\\ displayed\\ at\\ the\\ facility\\ entrance\\ to\\ start\\ (.*?)\\.\$',
        ),
        '__ARG0__ ಅನ್ನು ಪ್ರಾರಂಭಿಸಲು ಸೌಲಭ್ಯದ ಪ್ರವೇಶದ್ವಾರದಲ್ಲಿ ಪ್ರದರ್ಶಿಸಲಾದ QR ಅನ್ನು ಬಳಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Verify\\ OTP\\ API\\ error:\\ (.*?)\$'),
        'OTP API ದೋಷವನ್ನು ಪರಿಶೀಲಿಸಿ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^W(.*?)\$'), 'ಡಬ್ಲ್ಯೂ__ಎಆರ್‌ಜಿ0__'),
      _LocalizedPattern(
        RegExp('^Waiting\\ for\\ (.*?)\$'),
        '__ARG0__ ಗಾಗಿ ಕಾಯಲಾಗುತ್ತಿದೆ',
      ),
      _LocalizedPattern(
        RegExp('^Water\\ logged\\ locally:\\ (.*?)\\ ml\$'),
        'ಸ್ಥಳೀಯವಾಗಿ ಸಂಗ್ರಹವಾಗಿರುವ ನೀರು: __ARG0__ ಮಿಲಿ',
      ),
      _LocalizedPattern(RegExp('^Week\\ (.*?)\$'), 'ವಾರ __ARG0__'),
      _LocalizedPattern(
        RegExp('^Week\\ (.*?)\\ of\\ (.*?)\$'),
        '__ARG1__ ರ __ARG0__ ವಾರ',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ bridge\\ unavailable:\\ (.*?)\$'),
        'ವ್ಯಾಯಾಮ ಹಿನ್ನೆಲೆ ಸೇತುವೆ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ service\\ stop\\ failed:\\ (.*?)\$'),
        'ವ್ಯಾಯಾಮ ಹಿನ್ನೆಲೆ ಸೇವೆಯ ನಿಲುಗಡೆ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Workout\\ background\\ service\\ stop\\ unavailable:\\ (.*?)\$',
        ),
        'ವ್ಯಾಯಾಮ ಹಿನ್ನೆಲೆ ಸೇವಾ ನಿಲ್ದಾಣ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ background\\ service\\ unavailable:\\ (.*?)\$'),
        'ವ್ಯಾಯಾಮ ಹಿನ್ನೆಲೆ ಸೇವೆ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ feedback\\ request\\ failed\\ \\((.*?)\\)\$'),
        'ವ್ಯಾಯಾಮ ಪ್ರತಿಕ್ರಿಯೆ ವಿನಂತಿ ವಿಫಲವಾಗಿದೆ (__ARG0__)',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ location\\ monitoring\\ error:\\ (.*?)\$'),
        'ವ್ಯಾಯಾಮ ಸ್ಥಳ ಮೇಲ್ವಿಚಾರಣೆ ದೋಷ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ report\\ \\-\\ (.*?)\$'),
        'ವ್ಯಾಯಾಮ ವರದಿ - __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^Workout\\ started\\.\\ Turn\\ on\\ Location\\ and\\ allow\\ it\\ for\\ (.*?)\\ to\\ receive\\ the\\ automatic\\ 2\\ km\\ checkout\\ reminder\\.\$',
        ),
        'ವ್ಯಾಯಾಮ ಪ್ರಾರಂಭವಾಗಿದೆ. ಸ್ಥಳವನ್ನು ಆನ್ ಮಾಡಿ ಮತ್ತು __ARG0__ ಗೆ ಸ್ವಯಂಚಾಲಿತ 2 ಕಿಮೀ ಚೆಕ್ಔಟ್ ಜ್ಞಾಪನೆಯನ್ನು ಸ್ವೀಕರಿಸಲು ಅನುಮತಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ hide\\ failed:\\ (.*?)\$'),
        'ವರ್ಕ್‌ಔಟ್ ಟೈಮರ್ ಮೇಲ್ಮೈ ಮರೆಮಾಡುವಿಕೆ ವಿಫಲವಾಗಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ hide\\ unavailable:\\ (.*?)\$'),
        'ವರ್ಕೌಟ್ ಟೈಮರ್ ಸರ್ಫೇಸ್ ಹೈಡ್ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^Workout\\ timer\\ surface\\ unavailable:\\ (.*?)\$'),
        'ವರ್ಕ್‌ಔಟ್ ಟೈಮರ್ ಮೇಲ್ಮೈ ಲಭ್ಯವಿಲ್ಲ: __ARG0__',
      ),
      _LocalizedPattern(RegExp('^Yesterday,\\ (.*?)\$'), 'ನಿನ್ನೆ, __ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^You\\ already\\ booked\\ (.*?)\\ at\\ (.*?)\\ \\((.*?)\\)\\.\\ Choose\\ a\\ different\\ hour\\ or\\ cancel\\ that\\ booking\\ first\\.\$',
        ),
        'ನೀವು ಈಗಾಗಲೇ __ARG1__ (__ARG2__) ನಲ್ಲಿ __ARG0__ ಬುಕ್ ಮಾಡಿದ್ದೀರಿ. ಬೇರೆ ಗಂಟೆಯನ್ನು ಆರಿಸಿ ಅಥವಾ ಮೊದಲು ಆ ಬುಕಿಂಗ್ ಅನ್ನು ರದ್ದುಗೊಳಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^You\\ are\\ checked\\ in\\ for\\ (.*?)\\.\\ Check\\ out\\ when\\ the\\ session\\ ends\\.\$',
        ),
        'ನೀವು __ARG0__ ಗೆ ಚೆಕ್ ಇನ್ ಆಗಿದ್ದೀರಿ. ಸೆಷನ್ ಮುಗಿದಾಗ ಪರಿಶೀಲಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^You\\ started\\ at\\ (.*?)\\ over\\ an\\ hour\\ ago\\.\\ End\\ the\\ workout\\ session\\ when\\ you\\ are\\ done\\.\$',
        ),
        'ನೀವು ಒಂದು ಗಂಟೆಯ ಹಿಂದೆ __ARG0__ ನಲ್ಲಿ ಪ್ರಾರಂಭಿಸಿದ್ದೀರಿ. ನೀವು ಮುಗಿಸಿದ ನಂತರ ವ್ಯಾಯಾಮ ಅವಧಿಯನ್ನು ಕೊನೆಗೊಳಿಸಿ.',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ (.*?)\\ Care\\ Program\\ progress\\ report\\.\$'),
        'ನಿಮ್ಮ __ARG0__ ಆರೈಕೆ ಕಾರ್ಯಕ್ರಮದ ಪ್ರಗತಿ ವರದಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ has\\ been\\ notified\\ to\\ retry\\ your\\ plan\\.\$',
        ),
        'ನಿಮ್ಮ ಯೋಜನೆಯನ್ನು ಮರುಪ್ರಯತ್ನಿಸಲು ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ಗೆ ಸೂಚಿಸಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ is\\ generating\\ a\\ draft\\ for\\ review\\.\$',
        ),
        'ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ಪರಿಶೀಲನೆಗಾಗಿ ಡ್ರಾಫ್ಟ್ ಅನ್ನು ರಚಿಸುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ company\\ (.*?)\\ is\\ preparing\\ your\\ plan\\.\$'),
        'ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ನಿಮ್ಮ ಯೋಜನೆಯನ್ನು ಸಿದ್ಧಪಡಿಸುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ company\\ (.*?)\\ is\\ reviewing\\ your\\ plan\\ before\\ approval\\.\$',
        ),
        'ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ಅನುಮೋದನೆಗೆ ಮುನ್ನ ನಿಮ್ಮ ಯೋಜನೆಯನ್ನು ಪರಿಶೀಲಿಸುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ completed\\ (.*?)\\ workout\\ report\\.\$'),
        'ನಿಮ್ಮ ಪೂರ್ಣಗೊಂಡ __ARG0__ ತಾಲೀಮು ವರದಿ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ plan\\ renewal\\ is\\ being\\ prepared\\ by\\ your\\ company\\ (.*?)\\.\$',
        ),
        'ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ನಿಮ್ಮ ಯೋಜನೆಯ ನವೀಕರಣವನ್ನು ಸಿದ್ಧಪಡಿಸುತ್ತಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ report\\ is\\ saved\\.\\ Your\\ current\\ app\\ BMI\\ is\\ (.*?)\\.\$',
        ),
        'ನಿಮ್ಮ ವರದಿಯನ್ನು ಉಳಿಸಲಾಗಿದೆ. ನಿಮ್ಮ ಪ್ರಸ್ತುತ ಅಪ್ಲಿಕೇಶನ್ BMI __ARG0__ ಆಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp(
          '^Your\\ request\\ has\\ been\\ sent\\ to\\ your\\ company\\ (.*?)\\.\$',
        ),
        'ನಿಮ್ಮ ವಿನಂತಿಯನ್ನು ನಿಮ್ಮ ಕಂಪನಿ __ARG0__ ಗೆ ಕಳುಹಿಸಲಾಗಿದೆ.',
      ),
      _LocalizedPattern(
        RegExp('^Your\\ specialist\\-approved\\ (.*?)\\ plan\\.\$'),
        'ನಿಮ್ಮ ತಜ್ಞರು ಅನುಮೋದಿಸಿದ __ARG0__ ಯೋಜನೆ.',
      ),
      _LocalizedPattern(RegExp('^alert\\-(.*?)\$'), 'ಎಚ್ಚರಿಕೆ-__ARG0__'),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)\$'),
        'ಸರಾಸರಿ / ಗುರಿ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)h\$'),
        'ಸರಾಸರಿ / ಗುರಿ __ARG0__ಗಂ',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)\$'),
        'ಸರಾಸರಿ / ಗುರಿ __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^avg\\ /\\ target\\ (.*?)ml\$'),
        'ಸರಾಸರಿ / ಗುರಿ __ARG0__ml',
      ),
      _LocalizedPattern(
        RegExp('^care\\-program\\-progress\\-(.*?)\\.pdf\$'),
        'ಆರೈಕೆ-ಕಾರ್ಯಕ್ರಮ-ಪ್ರಗತಿ-__ARG0__.pdf',
      ),
      _LocalizedPattern(RegExp('^ecg\\-(.*?)\$'), 'ಇಸಿಜಿ-__ARG0__'),
      _LocalizedPattern(RegExp('^exercise\\-(.*?)\$'), 'ವ್ಯಾಯಾಮ-__ARG0__'),
      _LocalizedPattern(RegExp('^extra\\-(.*?)\$'), 'ಹೆಚ್ಚುವರಿ-__ARG0__'),
      _LocalizedPattern(
        RegExp(
          '^health\\.installHealthConnect\\ failed,\\ falling\\ back:\\ (.*?)\$',
        ),
        'health.installHealthConnect ವಿಫಲವಾಗಿದೆ, ಹಿಂತಿರುಗುತ್ತಿದೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^metric:(.*?):(.*?)\$'),
        'ಮೆಟ್ರಿಕ್:__ARG0__:__ARG1__',
      ),
      _LocalizedPattern(RegExp('^of\\ (.*?)\\ pts\$'), '__ARG0__ ಅಂಕಗಳಲ್ಲಿ'),
      _LocalizedPattern(
        RegExp('^session_exclusion:(.*?)\$'),
        'ಅಧಿವೇಶನ_ಹೊರತುಪಡಿಸುವಿಕೆ:__ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^session_type:(.*?)\$'),
        'ಅಧಿವೇಶನ_ಪ್ರಕಾರ:__ARG0__',
      ),
      _LocalizedPattern(
        RegExp('^\\}(.*?)\\ vs\\ previous\\ 7\\ days\$'),
        '}__ARG0__ vs ಹಿಂದಿನ 7 ದಿನಗಳು',
      ),
      _LocalizedPattern(
        RegExp('^\\}(.*?)\\ (.*?)\$'),
        '}__ಎಆರ್‌ಜಿ0___ __ಎಆರ್‌ಜಿ1__',
      ),
      _LocalizedPattern(
        RegExp('^·\\ (.*?)/(.*?)\\ extra\$'),
        '· __ARG0__/__ARG1__ ಹೆಚ್ಚುವರಿ',
      ),
      _LocalizedPattern(
        RegExp(
          '^✅\\ Dashboard\\ synced\\ —\\ daily\\ steps:\\ (.*?),\\ weekly\\ average\\ steps:\\ (.*?),\\ score:\\ (.*?),\\ calories:\\ (.*?),\\ sleep:\\ (.*?),\\ water:\\ (.*?),\\ rewards:\\ (.*?),\\ challenges:\\ (.*?)\$',
        ),
        '✅ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಸಿಂಕ್ ಮಾಡಲಾಗಿದೆ — ದೈನಂದಿನ ಹಂತಗಳು: __ARG0__, ವಾರದ ಸರಾಸರಿ ಹಂತಗಳು: __ARG1__, ಸ್ಕೋರ್: __ARG2__, ಕ್ಯಾಲೋರಿಗಳು: __ARG3__, ನಿದ್ರೆ: __ARG4__, ನೀರು: __ARG5__, ಬಹುಮಾನಗಳು: __ARG6__, ಸವಾಲುಗಳು: __ARG7__',
      ),
      _LocalizedPattern(
        RegExp('^✅\\ GET\\ Dashboard\\ done\\ —\\ widgets\\ count:\\ (.*?)\$'),
        '✅ ಡ್ಯಾಶ್‌ಬೋರ್ಡ್ ಅನ್ನು ಪೂರ್ಣಗೊಳಿಸಿ — ವಿಜೆಟ್‌ಗಳ ಎಣಿಕೆ: __ARG0__',
      ),
      _LocalizedPattern(
        RegExp(
          '^✅\\ Sync\\ POST\\ done\\ —\\ score:\\ (.*?),\\ water:\\ (.*?)\$',
        ),
        '✅ ಪೋಸ್ಟ್ ಸಿಂಕ್ ಮಾಡಲಾಗಿದೆ — ಸ್ಕೋರ್: __ARG0__, ನೀರು: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^🌙\\ (.*?)h\$'), '🌙 __ARG0__ಗಂ'),
      _LocalizedPattern(RegExp('^💧\\ (.*?)ml\$'), '💧 __ARG0__ಮಿಲಿ'),
      _LocalizedPattern(
        RegExp('^🔍\\ widgetsData\\ count:\\ (.*?),\\ titles:\\ (.*?)\$'),
        '🔍 ವಿಜೆಟ್‌ಗಳುಡೇಟಾ ಎಣಿಕೆ: __ARG0__, ಶೀರ್ಷಿಕೆಗಳು: __ARG1__',
      ),
      _LocalizedPattern(RegExp('^🔥\\ (.*?)\$'), '🔥 __ARG0___ 🔥 ಕನ್ನಡ'),
      _LocalizedPattern(RegExp('^🚶\\ (.*?)\$'), '🚶 __ARG0___'),
    ],
  };
}

class _LocalizedPattern {
  const _LocalizedPattern(this.expression, this.translation);
  final RegExp expression;
  final String translation;
}
