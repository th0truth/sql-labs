/**
 * Лабораторна робота №4: Клієнтська валідація та інтерактивність (Рівень 3)
 */

document.addEventListener("DOMContentLoaded", function () {
  // Закриття Flash повідомлень
  const closeButtons = document.querySelectorAll(".alert .close-btn");
  closeButtons.forEach((btn) => {
    btn.addEventListener("click", function () {
      this.closest(".alert").remove();
    });
  });

  // Клієнтська валідація форми додавання/редагування книги
  const bookForm = document.querySelector("#book-form");
  if (bookForm) {
    bookForm.addEventListener("submit", function (e) {
      const priceInput = document.querySelector("#price");
      const stockInput = document.querySelector("#stock_quantity");
      const yearInput = document.querySelector("#publication_year");
      const isbnInput = document.querySelector("#isbn");

      let hasError = false;
      let errorMessages = [];

      if (priceInput && parseFloat(priceInput.value) < 0) {
        hasError = true;
        errorMessages.push("Ціна не може бути меншою за 0 грн.");
      }

      if (stockInput && parseInt(stockInput.value) < 0) {
        hasError = true;
        errorMessages.push("Кількість на складі не може бути від'ємною.");
      }

      if (yearInput) {
        const year = parseInt(yearInput.value);
        const currentYear = new Date().getFullYear();
        if (year < 1000 || year > currentYear + 1) {
          hasError = true;
          errorMessages.push(`Рік публікації має бути в діапазоні від 1000 до ${currentYear + 1}.`);
        }
      }

      if (isbnInput) {
        const isbn = isbnInput.value.trim();
        if (isbn.length < 10) {
          hasError = true;
          errorMessages.push("ISBN повинен містити не менше 10 символів.");
        }
      }

      if (hasError) {
        e.preventDefault();
        alert("⚠️ Помилка клієнтської валідації:\n\n• " + errorMessages.join("\n• "));
      }
    });
  }
});
