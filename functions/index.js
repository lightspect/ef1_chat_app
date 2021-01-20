const functions = require('firebase-functions')
const admin = require('firebase-admin')
const algoliasearch = require('algoliasearch');
const { firestore } = require('firebase-admin');

const ALGOLIA_ID = "GDVJZMIBQ9"; //ApplicationID
const ALGOLIA_ADMIN_KEY = "7aa52990ab3f4f023c7e973f7e1e3a62"; //Admin API Key
const algoliaClient = algoliasearch(ALGOLIA_ID, ALGOLIA_ADMIN_KEY);

admin.initializeApp()

exports.sendNotification = functions.firestore
  .document('messages/{groupId}/messages/{messageId}')
  .onCreate(async (snap, context) => {
    console.log('----------------start function--------------------')

    const doc = snap.data()
    const groupId = snap.ref.parent.parent.id

    const senderId = doc.sentBy
    var contentMessage = ""
    const promises = []   

    const groups = await admin.firestore().doc("groups/" + groupId).get()
    const memberData = groups.data().membersList
    var groupName = groups.data().groupName

    if(doc.type === 1 || doc.type === 2 || doc.type === 3) {
      contentMessage = doc.messageContent
    } else {
      contentMessage = "(Photo)"
    }
    memberData.forEach(async (memberId) => {
      const member = admin.firestore().doc("users/" + memberId["userId"]).get()
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
        type: 'newMessage',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
        groupId: groupId,
      },
      tokens: memberToken,
    }
    if(memberToken.length > 0 && doc.type != 4) {
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

exports.setAlgoliaApp = functions.firestore.document("messages/{groupID}/messages/{messageID}").onWrite((change, context) => {
  
  if(!change.before.exists && change.after.exists) {
    const message = change.after.data();
    message.objectID = change.after.id;
    const groupId = change.after.ref.parent.parent.id;
    
    const index = algoliaClient.initIndex(groupId);

    index.saveObject(message);
  } else if (change.before.exists && change.after.exists) {
    if(change.before.data().messageContent !== change.after.data().messageContent) {
      const message = change.after.data();
      message.objectID = change.after.id;
      const groupId = change.after.ref.parent.parent.id;
      
      const index = algoliaClient.initIndex(groupId);

      index.saveObject(message);
    } else if (change.before.exists && !change.after.exists) {
      const groupId = change.after.ref.parent.parent.id;
      
      const index = algoliaClient.initIndex(groupId);
      index.deleteObject(change.before.id);
    }
  }
})

exports.sendGroupUpdate = functions.firestore.document("groups/{groupId}").onUpdate(async (change, context) => {
  if(change.before.data().membersList.length < change.after.data().membersList.length) {
    const groupId = change.after.data().groupId;
    const promises = [];
    const resultPromises = [];

    var before = change.before.data().membersList;
    var after = change.after.data().membersList;

    function comparer(otherArray){
      return function(current){
        return otherArray.filter(function(other){
          return other.value == current.value && other.display == current.display
        }).length == 0;
      }
    }

    var inBefore = before.filter(comparer(after));
    var inAfter = after.filter(comparer(before));

    const result = inBefore.concat(inAfter);

    console.log(result);

    result.forEach(async (memberId) => {
      const member = admin.firestore().doc("users/" + memberId["userId"]).get();
      resultPromises.push(member);
    })

    const resultSnap = await Promise.all(promises);

    after.forEach(async (memberId) => {
      const member = admin.firestore().doc("users/" + memberId["userId"]).get();
      promises.push(member);
    })

    const snapshots = await Promise.all(promises);

    const memberToken = []
    snapshots.forEach(snap => {
      const data = snap.data().token
      if(data !== undefined && data !== "") {
        if(groups.data().type === 1) {
          groupName = snap.data().nickname
        }
        memberToken.push(data) 
      }
    })

    const payload = {
      data : {
        type: 'addMember',
        result: resultSnap,
        groupId: groupId,
      },
      tokens: memberToken,
    }

    if(memberToken.length > 0) {
      admin.messaging().sendMulticast(payload).then(response => {
        console.log('Successfully Update MemberList:', response)
        if (response.failureCount > 0) {
          response.responses.forEach((resp, idx) => {
            if (!resp.success) {
              console.log(resp.error);
            }
          })
        }
      })
      .catch(error => {
        console.log('Error Update MemberList:', error)
      })
    }
    return null
  }
})