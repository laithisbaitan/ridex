import React, { useState, useEffect } from 'react'
import { MapContainer, Marker, Popup, TileLayer } from 'react-leaflet'
import { Socket } from 'phoenix'
import { usePosition } from '../lib/usePosition'
import Geohash from 'latlon-geohash'

const geohashFromPosition = (position) =>
    position ? Geohash.encode(position.lat, position.lng, 5) : ""


export default ({ user }) => {
    const position = usePosition()
    const [channel, setChannel] = useState()
    const [rideRequests, setRideRequests] = useState([])
    const [userChannel, setUserChannel] = useState()
    
    const requestRide = () => channel.push('ride:request', { position: position })

    useEffect(() => {
        const socket = new Socket('/socket', {params: {token: user.token}});
        socket.connect()

        if (!position) {
            return
        }

        const phxChannel = socket.channel('cell:' + geohashFromPosition(position))
        phxChannel.join().receive('ok', response => {
            console.log('Joined channel!')
            setChannel(phxChannel)
        })

        const phxUserChannel = socket.channel('user:' + user.id)
        phxUserChannel.join().receive('ok', response => {
            console.log('Joined user channel!')
            setUserChannel(phxUserChannel)
        })

        return () => phxChannel.leave()
    }, [
        // We need to pass the geohash as a useEffect dependency,
        // so we can reconnect to a different channel when current position's geohash changes
        geohashFromPosition(position)
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