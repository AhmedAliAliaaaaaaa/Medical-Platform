// مترجم مبسط للاختبار
console.log("🔄 تحميل المترجم المبسط...");

document.addEventListener("DOMContentLoaded", function () {
  console.log("✅ DOM جاهز");

  // البحث عن الأزرار
  const translateBtn = document.getElementById("translateBtn");
  const originalText = document.getElementById("originalText");
  const translatedText = document.getElementById("translatedText");
  const translationStatus = document.getElementById("translationStatus");

  console.log("🔍 فحص العناصر:");
  console.log("translateBtn:", translateBtn ? "✅ موجود" : "❌ مفقود");
  console.log("originalText:", originalText ? "✅ موجود" : "❌ مفقود");
  console.log("translatedText:", translatedText ? "✅ موجود" : "❌ مفقود");
  console.log(
    "translationStatus:",
    translationStatus ? "✅ موجود" : "❌ مفقود"
  );

  if (!translateBtn) {
    console.error("❌ زر الترجمة غير موجود!");
    return;
  }

  if (!originalText) {
    console.error("❌ حقل النص الأصلي غير موجود!");
    return;
  }

  console.log("🔗 ربط زر الترجمة...");

  translateBtn.addEventListener("click", async function () {
    console.log("🖱️ تم الضغط على زر الترجمة!");

    const text = originalText.value.trim();
    if (!text) {
      alert("يرجى كتابة نص للترجمة");
      return;
    }

    console.log("📝 النص المراد ترجمته:", text);

    if (translationStatus) {
      translationStatus.innerHTML =
        '<div class="spinner-border spinner-border-sm me-2"></div>جاري الترجمة...';
    }

    try {
      console.log("📡 إرسال طلب الترجمة...");

      const response = await fetch("/patients/api/translate/", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRFToken": document.querySelector("[name=csrfmiddlewaretoken]")
            .value,
        },
        body: JSON.stringify({
          text: text,
          source_language: "ar",
          target_language: "en",
        }),
      });

      console.log("📊 كود الاستجابة:", response.status);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();
      console.log("📥 البيانات المستلمة:", data);

      if (data.success) {
        if (translatedText) {
          translatedText.value = data.translated_text;
        }
        if (translationStatus) {
          translationStatus.innerHTML =
            '<span class="text-success">✅ تمت الترجمة بنجاح!</span>';
        }
        console.log("✅ نجحت الترجمة:", data.translated_text);
      } else {
        throw new Error(data.error || "فشل في الترجمة");
      }
    } catch (error) {
      console.error("❌ خطأ في الترجمة:", error);
      if (translationStatus) {
        translationStatus.innerHTML = `<span class="text-danger">❌ خطأ: ${error.message}</span>`;
      }
      alert("حدث خطأ في الترجمة: " + error.message);
    }
  });

  console.log("✅ تم إعداد المترجم المبسط بنجاح!");
});
