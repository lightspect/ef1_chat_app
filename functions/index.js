const functions = require('firebase-functions')
const admin = require('firebase-admin')
admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    const groupId = snap.ref.parent.parent.id

    const senderId = doc.sentBy
    const contentMessage = doc.messageContent
    const promises = []   

    const groups = await admin.firestore().doc("groups/" + groupId).get()
    const memberData = groups.data().members
    var groupName = groups.data().groupName
    memberData.forEach(async (memberId) => {
      const member = admin.firestore().doc("users/" + memberId).get()
      promises.push(member)
    })

    const snapshots = await Promise.all(promises)

    const memberToken = []
    snapshots.forEach(snap => {
      const data = snap.data().token
      if(senderId !== snap.data().id && data !== undefined && data !== "") {
        if(groups.data().type === 1) {
          groupName = snap.data().nickname
        }
        memberToken.push(data) 
      }
    })

    console.log(memberToken)
    const payload = {
      notification: {
        title: 'You have a new Message from ' + groupName,
        body: contentMessage,
      },
      data : {
        groupId: groupId,
      },
      tokens: memberToken,
      android: {
        notification: {
            clickAction: 'FLUTTER_NOTIFICATION_CLICK',
        },
      }
    }
    if(memberToken.length > 0) {
      admin.messaging().sendMulticast(payload).then(response => {
        console.log('Successfully sent message:', response)
        if (response.failureCount > 0) {
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              console.log(resp.error);
            }
          })
        }
      })
      .catch(error => {
        console.log('Error sending message:', error)
      })
    }
    return null
  })