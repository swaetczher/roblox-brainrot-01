-- RemoteEvent client-server: dibuat sekali di ReplicatedStorage.
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = {}

local folder = Instance.new("Folder")
folder.Name = "Remotes"
folder.Parent = ReplicatedStorage

local daftar = {"UpdateHUD", "BeriPesan", "AksiKunci", "AksiRebirth", "AksiTampar", "AksiTelur", "AksiTeleport"}
for _, nama in ipairs(daftar) do
	local remote = Instance.new("RemoteEvent")
	remote.Name = nama
	remote.Parent = folder
end

function Remotes.ambil(namaRemote)
	return folder:WaitForChild(namaRemote)
end

Remotes.Folder = folder

return Remotes
