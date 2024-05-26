import React, { useState, useEffect } from 'react'
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet'
import { Socket, Presence} from 'phoenix'
import { usePosition } from '../lib/usePosition'
import Geohash from 'latlon-geohash'

const geohashFromPosition = (position) =>
    position ? Geohash.encode(position.lat, position.lng, 5) : ""


export default ({ user }) => {
    const position = usePosition()
    const [channel, setChannel] = useState()
    const [rideRequests, setRideRequests] = useState([])
    const [userChannel, setUserChannel] = useState()
    const [presences, setPresences] = useState({})
    
    const requestRide = () => channel.push('ride:request', { position: position })
    const getLat = (position) => position ? position.lat : 0
    const getLng = (position) => position ? position.lng : 0

    useEffect(() => {
        const socket = new Socket('/socket', {params: {token: user.token}});
        socket.connect()

        if (!position) {
            return
        }

        const phxChannel = socket.channel('cell:' + geohashFromPosition(position), position)
        phxChannel.join().receive('ok', response => {
            console.log('Joined channel!')
            setChannel(phxChannel)
        })

        const phxUserChannel = socket.channel('user:' + user.id)
        phxUserChannel.join().receive('ok', response => {
            console.log('Joined user channel!')
            setUserChannel(phxUserChannel)
        })

        if (userChannel) {
            userChannel.push('update_position', position)
        }
        return () => phxChannel.leave()
    }, [
        // We need to pass the geohash as a useEffect dependency,
        // so we can reconnect to a different channel when current position's geohash changes
        geohashFromPosition(position),
        getLat(position),
        getLng(position)
    ])

    if (!position) {
        return (<div>Awaiting for position...</div>)
    }
    if (!channel || !userChannel) {
        return (<div>Connecting to channel...</div>)
    }
    
    channel.on('ride:requested', rideRequest =>
        setRideRequests(rideRequests.concat([rideRequest]))
    )
    
    userChannel.on('ride:created', ride =>
        console.log('A ride has been created!')
    )

    channel.on('presence_state', state => {
        let syncedPresences = Presence.syncState(presences, state)
        setPresences(syncedPresences)
    })
    const positionsFromPresences = Presence.list(presences)
        .filter(presence => !!presence.metas)
        .map(presence => presence.metas[0])

    channel.on('presence_diff', response => {
        let syncedPresences = Presence.syncDiff(presences, response)
        setPresences(syncedPresences)
    })
    
    let acceptRideRequest = (request_id) => channel.push('ride:accept_request', {
        request_id
    })

    return (
        <div>
        Logged in as {user.type}
        
        {user.type == 'rider' && (<div>
            <button onClick={requestRide}>Request Ride</button>
        </div>)}

        <MapContainer center={position} zoom={15}>
            <TileLayer
                url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
                attribution="&copy; <a href=&quot;http://osm.org/copyright&quot;>OpenStreetMap</a> contributors"
            />

            <Marker position={position} />

            {positionsFromPresences.map(({ lat, lng, phx_ref }) => (
                <Marker key={phx_ref} position={{ lat, lng }} />
            ))}

            {rideRequests.map(({request_id, position}) => (
            <Marker key={request_id} position={position}>
                <Popup>
                New ride request
                <button onClick={() => acceptRideRequest(request_id)}>Accept</button>
                </Popup>
            </Marker>
            ))}
        </MapContainer>
        </div>
    )
}