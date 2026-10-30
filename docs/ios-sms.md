---
title: Add expenses from bank SMS on iPhone
permalink: /ios-sms/
---

# Add expenses from bank SMS on iPhone

On Android, Expense Manager can read bank SMS directly. **iOS doesn't let any app read your messages**, so on iPhone you set up a small Shortcuts automation once. Whenever a bank, card or UPI SMS arrives, the automation hands its text to Expense Manager, which:

1. reads it **on your iPhone** (nothing is uploaded),
2. skips OTPs, offers, bill reminders and failed payments,
3. shows a notification like **"New expense: ₹250 at Swiggy"** with **Add**, **Add details** and **Ignore**.

**Add** saves it straight away and shows **"Expense added"** with an **Undo** button. **Add details** opens the add form already filled in.

**You need:** iOS 17 or later (iOS 16 works, but asks before every run), and Expense Manager installed and opened once.

## 1. Turn it on in the app

Open **Expense Manager → Settings → Expenses from SMS** and switch on **Ask to add bank SMS**. Allow notifications when asked; the prompts are notifications.

## 2. Create the automation

1. Open the **Shortcuts** app and tap the **Automation** tab.
2. Tap **+** (or **New Automation**) and choose **Message**.
3. Next to **Message Contains**, type `debited`. Leave **Sender** empty so every bank is covered.
4. Choose **Run Immediately**, and turn off **Notify When Run** if you see it. Tap **Next**.
5. Tap **New Blank Automation**, then **Add Action**.
6. Search for **Log bank SMS** and pick the one from **Expense Manager**.
7. In the action, tap the blue **Message** field and choose **Shortcut Input** (the message that triggered the automation). If it shows as *Shortcut Input → Message*, tap it and pick **Content**.
8. Tap **Done**.

## 3. Add a few more words

One automation matches one word. Repeat step 2 with these to catch most banks and UPI apps:

| Message contains | Catches |
| --- | --- |
| `debited` | UPI payments, account debits (most banks) |
| `spent` | card purchases (HDFC, ICICI, Axis…) |
| `credited` | salary, refunds, money received |
| `sent Rs` | HDFC / Kotak UPI "Sent Rs.250…" messages |

Messages that match more than one rule are only asked about once.

## 4. Try it

Send yourself a test SMS from another phone, for example:

> Sent Rs.10.00 From HDFC Bank A/C *1234 To SWIGGY On 30/10/26 Ref 630212345678

Within a few seconds you should see **"New expense: ₹10 at Swiggy"**. Tap **Ignore** to drop it.

## Troubleshooting

- **No notification:** check that **Expenses from SMS** is on in the app, that notifications are allowed for Expense Manager (Settings → Notifications), and that the automation is set to **Run Immediately**.
- **It asks "Run automation?" every time:** that happens on iOS 16. Update to iOS 17 or later to run it silently.
- **Payee shows as blank:** some banks don't name the merchant. The amount is still read; add the payee with **Add details**.
- **App lock or database encryption is on and the phone was locked:** the message is saved and you are asked about it the next time you open the app.
- **Missed a notification?** Open **Settings → Expenses from SMS**; anything not yet added or ignored waits under **To review**, and the home screen shows a banner.

## Privacy

The message text goes from the Shortcuts app to Expense Manager on the same phone. It is never sent to a server. Messages that aren't transactions are thrown away; handled ones are deleted after 30 days. See the [privacy policy](../privacy-policy/).

[← Expense Manager](../)
