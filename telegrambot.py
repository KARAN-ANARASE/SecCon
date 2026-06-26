from telegram.ext import *
import subprocess as ss
telegram_token = 'token'

updater = Updater(telegram_token, use_context=True)
dispatcher = updater.dispatcher

def start(update, context):
    name = update.effective_user.first_name
    update.message.reply_text("Welcome {}".format(name))

def message_handler(update, context):
    message = update.message
    out = ss.getoutput("subfinder -d {} -silent".format(message.text))
    update.message.reply_text(out)

dispatcher = updater.dispatcher
updater.dispatcher.add_handler(CommandHandler('start', start))
updater.dispatcher.add_handler(MessageHandler(Filters.text, message_handler))
updater.start_polling()
updater.idle()