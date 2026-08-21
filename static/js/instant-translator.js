// Instant Translator Script - Enhanced Version
document.addEventListener("DOMContentLoaded", function () {
  console.log("🔄 تحميل مترجم فوري...");
  // DOM Elements
  const originalText = document.getElementById("originalText");
  const translatedText = document.getElementById("translatedText");
  const translateBtn = document.getElementById("translateBtn");
  const useTranslationBtn = document.getElementById("useTranslationBtn");
  const clearTranslationBtn = document.getElementById("clearTranslationBtn");
  const swapLanguagesBtn = document.getElementById("swapLanguagesBtn");
  const sourceLanguage = document.getElementById("sourceLanguage");
  const targetLanguage = document.getElementById("targetLanguage");
  const targetLangName = document.getElementById("targetLangName");
  const sourceLangLabel = document.getElementById("sourceLangLabel");
  const translationStatus = document.getElementById("translationStatus");
  const descriptionField = document.querySelector(
    'textarea[name="description"]'
  );

  // تحقق من وجود العناصر
  console.log("🔍 فحص العناصر:");
  console.log("originalText:", originalText ? "✅" : "❌");
  console.log("translatedText:", translatedText ? "✅" : "❌");
  console.log("translateBtn:", translateBtn ? "✅" : "❌");
  console.log("sourceLanguage:", sourceLanguage ? "✅" : "❌");
  console.log("targetLanguage:", targetLanguage ? "✅" : "❌");
  console.log("translationStatus:", translationStatus ? "✅" : "❌");
  console.log("useTranslationBtn:", useTranslationBtn ? "✅" : "❌");
  console.log("clearTranslationBtn:", clearTranslationBtn ? "✅" : "❌");
  console.log("descriptionField:", descriptionField ? "✅" : "❌");

  // إذا لم تكن العناصر الأساسية موجودة، اخرج من الدالة
  if (!originalText || !translateBtn || !translationStatus) {
    console.error("❌ العناصر الأساسية للترجمة غير موجودة!");
    console.error("المطلوب: originalText, translateBtn, translationStatus");
    return;
  }

  // Language names mapping
  const languageNames = {
    en: "English",
    ar: "العربية",
    fr: "Français",
    es: "Español",
    de: "Deutsch",
    it: "Italiano",
    tr: "Türkçe",
    ru: "Русский",
    zh: "中文",
    ja: "日本語",
    ko: "한국어",
  };

  // Auto-detect source language based on text content
  function detectLanguage(text) {
    // Simple detection based on character patterns
    const arabicPattern = /[\u0600-\u06FF]/;
    return arabicPattern.test(text) ? "ar" : "en";
  }

  // Update target language name display
  if (targetLanguage && targetLangName) {
    targetLanguage.addEventListener("change", function () {
      targetLangName.textContent = languageNames[this.value];
    });
  }

  // Update source language label display
  if (sourceLanguage && sourceLangLabel) {
    sourceLanguage.addEventListener("change", function () {
      if (this.value === "auto") {
        sourceLangLabel.textContent = "النص الأصلي (تلقائي)";
      } else {
        sourceLangLabel.textContent = `النص الأصلي (${
          languageNames[this.value]
        })`;
      }
      // Update placeholder based on source language
      if (
        this.value === "en" ||
        (this.value === "auto" && detectLanguage(originalText.value) === "en")
      ) {
        originalText.placeholder = "Write your case description here...";
      } else {
        originalText.placeholder = "اكتب وصف حالتك هنا...";
      }
    });
  }

  // Swap languages function
  if (swapLanguagesBtn) {
    swapLanguagesBtn.addEventListener("click", function () {
      // Get current values
      const sourceValue = sourceLanguage.value;
      const targetValue = targetLanguage.value;

      // Swap the values
      sourceLanguage.value = targetValue;
      targetLanguage.value = sourceValue;

      // Update displays
      targetLangName.textContent = languageNames[targetValue];
      if (sourceLanguage.value === "auto") {
        sourceLangLabel.textContent = "النص الأصلي (تلقائي)";
      } else {
        sourceLangLabel.textContent = `النص الأصلي (${languageNames[sourceValue]})`;
      }

      // Swap text content
      const tempText = originalText.value;
      originalText.value = translatedText.value;
      translatedText.value = tempText;

      // Enable/disable buttons based on content
      if (useTranslationBtn) {
        useTranslationBtn.disabled = !originalText.value.trim();
      }
    });
  }

  // Translation function using internal API
  async function translateText(text, sourceLang, targetLang) {
    // Show loading status
    translationStatus.innerHTML =
      '<div class="spinner-border spinner-border-sm text-primary me-2"></div>جاري الترجمة...';

    try {
      // Get CSRF token (try multiple methods)
      let csrfToken = null;
      const csrfInput = document.querySelector("[name=csrfmiddlewaretoken]");
      if (csrfInput) {
        csrfToken = csrfInput.value;
      } else {
        // Try to get from cookie
        const csrfCookie = document.cookie
          .split(";")
          .find((cookie) => cookie.trim().startsWith("csrftoken="));
        if (csrfCookie) {
          csrfToken = csrfCookie.split("=")[1];
        }
      }

      // Use internal translation API
      const headers = {
        "Content-Type": "application/json",
      };

      if (csrfToken) {
        headers["X-CSRFToken"] = csrfToken;
      }

      const response = await fetch("/patients/api/translate/", {
        method: "POST",
        headers: headers,
        body: JSON.stringify({
          text: text,
          source_language: sourceLang === "auto" ? "auto" : sourceLang,
          target_language: targetLang,
        }),
      });

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      if (data.success) {
        translationStatus.innerHTML =
          '<span class="text-success"><i class="fas fa-check-circle me-1"></i>تمت الترجمة بنجاح</span>';
        return data.translated_text;
      } else {
        throw new Error(data.error || "Translation failed");
      }
    } catch (error) {
      console.error("Translation error:", error);
      translationStatus.innerHTML = `<span class="text-danger"><i class="fas fa-exclamation-circle me-1"></i>فشلت الترجمة: ${error.message}</span>`;

      // Return fallback translation
      if (targetLang === "ar") {
        return `[خطأ في الترجمة: ${text}]`;
      } else {
        return `[Translation error: ${text}]`;
      }
    }
  }

  // Translate button click handler
  if (translateBtn) {
    console.log("🔗 ربط زر الترجمة...");
    translateBtn.addEventListener("click", async function () {
      console.log("🖱️ تم الضغط على زر الترجمة");
      const text = originalText.value.trim();

      if (!text) {
        translationStatus.innerHTML =
          '<span class="text-danger"><i class="fas fa-exclamation-circle me-1"></i>الرجاء إدخال نص للترجمة</span>';
        return;
      }

      // Get source language (use selected value or auto-detect)
      let sourceLang = sourceLanguage.value;
      if (sourceLang === "auto") {
        sourceLang = detectLanguage(text);
      }

      // Get target language
      const targetLang = targetLanguage.value;

      // Don't translate if source and target languages are the same
      if (sourceLang === targetLang) {
        translationStatus.innerHTML =
          '<span class="text-warning"><i class="fas fa-info-circle me-1"></i>لغة المصدر والهدف متطابقة</span>';
        return;
      }

      try {
        // Disable button during translation
        translateBtn.disabled = true;
        translateBtn.innerHTML =
          '<i class="fas fa-spinner fa-spin me-2"></i>جاري الترجمة...';

        // Translate the text
        const translation = await translateText(text, sourceLang, targetLang);

        // Display the translation
        translatedText.value = translation;

        // Enable the "Use Translation" button
        useTranslationBtn.disabled = false;
      } catch (error) {
        translationStatus.innerHTML =
          '<span class="text-danger"><i class="fas fa-exclamation-circle me-1"></i>فشلت الترجمة، يرجى المحاولة مرة أخرى</span>';
        console.error("Translation error:", error);
      } finally {
        // Re-enable translate button
        translateBtn.disabled = false;
        translateBtn.innerHTML = '<i class="fas fa-language me-2"></i>ترجم';
      }
    });
  } else {
    console.error("❌ زر الترجمة غير موجود!");
  }

  // Use translation button click handler
  useTranslationBtn.addEventListener("click", function () {
    const translation = translatedText.value.trim();

    if (translation && descriptionField) {
      descriptionField.value = translation;

      // Trigger input event to update character counter
      const event = new Event("input", { bubbles: true });
      descriptionField.dispatchEvent(event);

      // Show success message
      translationStatus.innerHTML =
        '<span class="text-success"><i class="fas fa-check-circle me-1"></i>تم استخدام الترجمة في وصف الحالة</span>';
    }
  });

  // Clear translation button click handler
  clearTranslationBtn.addEventListener("click", function () {
    originalText.value = "";
    translatedText.value = "";
    useTranslationBtn.disabled = true;
    translationStatus.innerHTML = "";
  });

  // Sync original text with description field when description changes
  if (descriptionField) {
    descriptionField.addEventListener("input", function () {
      const sourceLang = detectLanguage(this.value);

      // If the description is in Arabic, update the original text field
      if (sourceLang === "ar") {
        originalText.value = this.value;
      }
    });

    // Initialize with current description value if it's in Arabic
    if (detectLanguage(descriptionField.value) === "ar") {
      originalText.value = descriptionField.value;
    }
  }

  // Make functions globally accessible
  window.translateText = translateText;
  window.useTranslation = function () {
    if (useTranslationBtn) useTranslationBtn.click();
  };
  window.clearTranslation = function () {
    if (clearTranslationBtn) clearTranslationBtn.click();
  };
  window.swapLanguages = function () {
    if (swapLanguagesBtn) swapLanguagesBtn.click();
  };
});
